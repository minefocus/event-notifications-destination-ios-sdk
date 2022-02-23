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
//  ENLoggerTests.swift
//  ENPushTests
//
//  Created by Anantha Krishnan K G on 14/02/22.
//

import XCTest
@testable import ENPushDestination

class ENLoggerTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testENLogger() throws {
        
        struct MessagePayload {
            let logLevel: String
            let message: String
            let caller: String
            let timeStamp: String
            let object: Dictionary<String, Any>?
        }
        
        let payload = MessagePayload(logLevel: "Info", message: "test Logger", caller: "testENLogger()", timeStamp: Date().debugDescription, object: ["customMessage": "Test logger data"])
       
        class ENLoggerMock : LogListener {
            
            var calledPayload : MessagePayload?
            var expectedExpection: XCTestExpectation?
            
            func logger(logLevel: String, message: String, caller: String, timeStamp: String, object: Dictionary<String, Any>?) {
                
                self.calledPayload = MessagePayload(logLevel: logLevel, message: message, caller: caller, timeStamp: timeStamp, object: object)
                self.expectedExpection?.fulfill()
            }
        }
        
        let expectation = XCTestExpectation(description: "test Logger called")
        let sutENLoggerMock = ENLoggerMock()
        sutENLoggerMock.expectedExpection = expectation
        ENLogger.sharedInstance.setLevel(.debug)
        ENLogger.sharedInstance.delegate = sutENLoggerMock
        
        ENLogger.sharedInstance.logger(logLevel: .info, message: payload.message, timeStamp: payload.timeStamp, object: payload.object)
        wait(for: [expectation], timeout: 0.5)
        
        XCTAssertNotNil(sutENLoggerMock.calledPayload)
        XCTAssertEqual(sutENLoggerMock.calledPayload!.message, payload.message)
        XCTAssertEqual(sutENLoggerMock.calledPayload!.caller, payload.caller)
        XCTAssertEqual(sutENLoggerMock.calledPayload!.timeStamp, payload.timeStamp)
        XCTAssertEqual(sutENLoggerMock.calledPayload!.logLevel, payload.logLevel)
        XCTAssertEqual(sutENLoggerMock.calledPayload!.object!.count, 1)

    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
