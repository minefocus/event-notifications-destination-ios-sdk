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
//  ENPushClientOptionsTests.swift
//  ENPushTests
//
//  Created by Anantha Krishnan K G on 14/02/22.
//

import XCTest
@testable import ENPushDestination

class ENPushClientOptionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let sut = ENPushClientOptions()
        sut.setInteractiveNotificationCategories(categoryName: [])
        let variables = ["username":"ananth","accountNumber":"3564758697057869"]
        sut.setDeviceId(deviceId: "testDeviceId")
        sut.setPushVariables(pushVariables: variables)
        XCTAssertEqual(sut.pushVariables, variables)
        
        XCTAssertEqual(sut.category, [])
        XCTAssertEqual(sut.deviceId, "testDeviceId")
        
        let actionOne = ENPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: .foreground)
        
        let actionTwo = ENPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: .destructive)
        
        let category = ENPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
        let sut2 = ENPushClientOptions()
        sut2.setDeviceId(deviceId: "")
        
        sut2.setInteractiveNotificationCategories(categoryName: [category])
        XCTAssertEqual(sut2.category, [category])
        XCTAssertEqual(sut2.deviceId, "")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
