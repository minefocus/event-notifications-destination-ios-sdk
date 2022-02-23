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
//  ENLocalPushNotificationTests.swift
//  ENPushTests
//
//  Created by Anantha Krishnan K G on 14/02/22.
//

import XCTest
@testable import ENPushDestination

class ENLocalPushNotificationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testENLocalPushNotification() throws {
        
        let alertBody = "Test body"
        let title = "Test alert"
        let subTitle = "Test subTitle"
        let sound = "sound"
        let badge: NSNumber = 23
        let categoryIdentifier = "Test_Category"
        let attachmentURL = ""
        let additionalPaylaod:[AnyHashable : Any] = [:]
        
        let localPush = ENLocalPushNotification(body: alertBody, title: title, subtitle: subTitle, sound: sound, badge: badge, categoryIdentifier: categoryIdentifier, attachments: attachmentURL, userInfo: additionalPaylaod)
        XCTAssertNotNil(localPush)
        
        let expectation = XCTestExpectation(description: "Alert should be called")
        
        class SenderPush: ENPushNotificationBuilder {
            var expecationInner: XCTestExpectation?
            var requestVal : UNNotificationRequest?
            
            func showENPushNotification(request: UNNotificationRequest) {
                requestVal = request
                expecationInner?.fulfill()
            }
        }
        
        let sutSenderPush = SenderPush()
        sutSenderPush.expecationInner = expectation
        localPush.builder = sutSenderPush
        localPush.showENPushNotification()
        wait(for: [expectation], timeout: 0.5)
        
        XCTAssertNotNil(sutSenderPush.requestVal)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
