/**
 (C) Copyright IBM Corp. 2021.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

//
//  ENPushTests.swift
//  ENPushTests
//
//  Created by Anantha Krishnan K G on 08/02/22.
//

import XCTest
@testable import ENPushDestination

enum ResponseType {
    case NoDevice
    case ExistingDevice
    case ExistingDeviceWithChange
    case DeviceAPIError
    case DeviceSuccess
    case SuccessResponse
    case ErrorResponse
}

var apiSequesnce: [ResponseType] = []

class ENPushTests: XCTestCase {
    
    
    class ObserverTest: ENPushObserver {
        var expectation: XCTestExpectation?
        var calledCount = 0
        var calledInit = false
        func onChangePermission(status: Bool) {
            self.calledCount += 1
            self.calledInit = status
            expectation?.fulfill()
        }
    }
    
    struct MockResponse<T:Codable> {
        let response:T?
        let statucCode: Int
        let error: String
    }
    
    var observer:ObserverTest?
    
    
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        observer = ObserverTest()
        sqizzleInstanceMethods(forClass: ENPush.self, originalSelector:  #selector(ENPush.initPushCenter(_:)), swizzledSelector: #selector(ENPush.initPushCenterSwizzle(_:)))

        sqizzleClassMethods(forClass: ENPushUtils.self, originalSelector:  #selector(ENPushUtils.saveValueToStorage(_:key:)), swizzledSelector: #selector(ENPushUtils.swizzleSaveValueToStorage(_:key:)))
        
        sqizzleClassMethods(forClass: ENPushUtils.self, originalSelector:  #selector(ENPushUtils.getValueFromStorage(key:)), swizzledSelector: #selector(ENPushUtils.swizzleGetValueFromStorage(key:)))
        
        sqizzleClassMethods(forClass: UNUserNotificationCenter.self, originalSelector:  #selector(UNUserNotificationCenter.current), swizzledSelector: #selector(UNUserNotificationCenter.swizzleCurrent))
    }
    
    override func tearDownWithError() throws {
        sqizzleInstanceMethods(forClass: ENPush.self, originalSelector:  #selector(ENPush.initPushCenter(_:)), swizzledSelector: #selector(ENPush.initPushCenterSwizzle(_:)))

        sqizzleClassMethods(forClass: ENPushUtils.self, originalSelector:  #selector(ENPushUtils.saveValueToStorage(_:key:)), swizzledSelector: #selector(ENPushUtils.swizzleSaveValueToStorage(_:key:)))
        
        sqizzleClassMethods(forClass: ENPushUtils.self, originalSelector:  #selector(ENPushUtils.getValueFromStorage(key:)), swizzledSelector: #selector(ENPushUtils.swizzleGetValueFromStorage(key:)))
        
        sqizzleClassMethods(forClass: UNUserNotificationCenter.self, originalSelector:  #selector(UNUserNotificationCenter.current), swizzledSelector: #selector(UNUserNotificationCenter.swizzleCurrent))
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testENPushVariables() throws {
        
        let sut = ENPush.sharedInstance
        
        let overrideServerHost = "https://localhost"
        ENPush.overrideServerHost = overrideServerHost
        
        XCTAssertEqual(overrideServerHost, ENPush.overrideServerHost)
        
        sut.setCloudRegion(region: .london)
        XCTAssertEqual(sut.getCloudRegion(), ENPush.Region.london.rawValue)
        
        sut.setCloudRegion(region: .sydney)
        XCTAssertEqual(sut.getCloudRegion(), ENPush.Region.sydney.rawValue)
        
        sut.setCloudRegion(region: .usSouth)
        XCTAssertEqual(sut.getCloudRegion(), ENPush.Region.usSouth.rawValue)
        
        sut.setLoggerLevel(.info)
        XCTAssertEqual(ENLogger.sharedInstance.level, .info)
        
        class ENLoggerMock : LogListener {
            func logger(logLevel: String, message: String, caller: String, timeStamp: String, object: Dictionary<String, Any>?) {}
        }
        
        let logger = ENLoggerMock()
        sut.setLogListener(logger)
        XCTAssertNotNil(ENLogger.sharedInstance.delegate)
    }
    
    func testENPushInitMethod() {
        
        let sut = ENPush.sharedInstance
        sut.setCloudRegion(region: .usSouth)
        
        let testGuid = "23442-42342-423423"
        let testDestinationID = "23442-42342-423423"
        let testAPIKey = "23442-42342-423423"

        let expectation = XCTestExpectation(description: "Test expectation")
        
        observer?.expectation = expectation
        sut.delegate = observer
        sut.initialize("", "", "")
        wait(for: [expectation], timeout: 0.5)
        
        XCTAssertEqual(observer?.calledCount, 1)
        XCTAssertEqual(observer?.calledInit, false)

        let newExpectation = XCTestExpectation(description: "Test expectation")
        observer?.expectation = newExpectation

        sut.initialize(testGuid, testDestinationID, testAPIKey)
        
        wait(for: [newExpectation], timeout: 0.5)
        
        XCTAssertEqual(observer?.calledCount, 2)
    }
    
    func testENPushInitMethodWithParams() {
        
        let sut = ENPush.sharedInstance
        sut.setCloudRegion(region: .usSouth)
        
        let testGuid = "23442-42342-423423"
        let testDestinationID = "23442-42342-423423"
        let testAPIKey = "23442-42342-423423"

        let actionOne = ENPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: .foreground)
        
        let actionTwo = ENPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: .destructive)
        
        let category = ENPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
        let options = ENPushClientOptions()
        options.setDeviceId(deviceId: "testDeviceId")
        options.setInteractiveNotificationCategories(categoryName: [category])

        let newExpectation = XCTestExpectation(description: "Test expectation")
        
        observer?.expectation = newExpectation
        sut.delegate = observer
        
        sut.initialize(testGuid, testDestinationID, testAPIKey, options)
        wait(for: [newExpectation], timeout: 0.5)
        
        XCTAssertEqual(observer?.calledCount, 1)
    }
    
    func testENPushAPICalls() {
        
        let sut = ENPush.sharedInstance
        sut.setCloudRegion(region: .usSouth)
        
        let testGuid = "23442-42342-423423"
        let testDestinationID = "23442-42342-423423"
        let testAPIKey = "23442-42342-423423"

        let token = "28d462a72b0d84f61e6faff85126d74da456f668551778146b80a6106fccb451".data(using: .utf8)
        
        sut.networkRequest = EnRestMock()
        
        let expectationNoInit = XCTestExpectation(description: "Should return error")
        sut.registerWithDeviceToken(deviceToken: token!, withUserId: "userId") { response, statusCode, error in
            XCTAssertEqual(statusCode, ENPushErrorvalues.ENPushRegistrationError.rawValue)
            expectationNoInit.fulfill()
        }
        
        wait(for: [expectationNoInit], timeout: 0.5)
        
       sut.initialize(testGuid, testDestinationID, testAPIKey)
        
        let expectationEmptyUser = XCTestExpectation(description: "Should return error")
        sut.registerWithDeviceToken(deviceToken: token!, withUserId: "") { response, statusCode, error in
            XCTAssertEqual(statusCode, ENPushErrorvalues.ENPushRegistrationError.rawValue)
            expectationEmptyUser.fulfill()
        }

        wait(for: [expectationEmptyUser], timeout: 0.5)
        
        
        apiSequesnce.removeAll()
        apiSequesnce = [.NoDevice,.DeviceSuccess]
        let expectationRegisterUser = XCTestExpectation(description: "Should be success")
        sut.registerWithDeviceToken(deviceToken: token!, withUserId: "userID") { response, statusCode, error in
            expectationRegisterUser.fulfill()
        }

        wait(for: [expectationRegisterUser], timeout: 0.5)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func sqizzleInstanceMethods(forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(forClass, originalSelector),
            let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    func sqizzleClassMethods(forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard
            let originalMethod = class_getClassMethod(forClass, originalSelector),
            let swizzledMethod = class_getClassMethod(forClass, swizzledSelector)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension ENPush {
    
    @objc func initPushCenterSwizzle(_ center: UNUserNotificationCenter ) {
        
    }
}

var storage: [String: Data?] = [:]

extension ENPushUtils {
    @objc dynamic open class func swizzleSaveValueToStorage(_ value:Data?, key:String) {
        storage[key, default: nil] = value
    }
    @objc dynamic open class func swizzleGetValueFromStorage(key:String) -> Data? {
        return storage[key, default: nil]
    }
}


extension UNUserNotificationCenter {
    
    @objc open class func swizzleCurrent() -> UNUserNotificationCenter? {
        return nil
    }
}

class EnRestMock: ENRestProtocol {
    
    
    func responseObject<T>(completionHandler: @escaping (T?, Int, String) -> Void) where T : Decodable {
        
        switch apiSequesnce.first! {
        case .NoDevice:
            apiSequesnce.removeFirst()
            completionHandler(nil, 404, "No device")
            break
        case .DeviceSuccess:
            completionHandler(ENDeviceModel(id: "deviceID", userID: "userID", token: "87639284", platform: "A") as? T, 201, "")
            break
        case .ExistingDevice:
            break
        case .ExistingDeviceWithChange:
            break
        case .DeviceAPIError:
            break
        
        case .SuccessResponse:
            break
        case .ErrorResponse:
            break
        }
    }
    
    func initRest(apikey: String, method: String, url: String, headerParameters: [String : String], queryItems: [URLQueryItem]?, messageBody: Data?) {}
    
    
}
