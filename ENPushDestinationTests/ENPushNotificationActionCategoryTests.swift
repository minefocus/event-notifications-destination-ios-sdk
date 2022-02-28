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
//  ENPushNotificationActionCategoryTests.swift
//  ENPushTests
//
//  Created by Anantha Krishnan K G on 14/02/22.
//

import XCTest
@testable import ENPushDestination

class ENPushNotificationActionCategoryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testENPushNotificationActionCategory() throws {
        
        let actionOne = ENPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: .foreground)
        
        let actionTwo = ENPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: .foreground)
        
        let actionThree = ENPushNotificationAction(identifierName: "Third", buttonTitle: "Delete", isAuthenticationRequired: false, defineActivationMode: .foreground)
        
        let actionFour = ENPushNotificationAction(identifierName: "Fourth", buttonTitle: "View", isAuthenticationRequired: false, defineActivationMode: .foreground)
        
        let actionFive = ENPushNotificationAction(identifierName: "Fifth", buttonTitle: "Later", isAuthenticationRequired: false, defineActivationMode: .destructive)
        
        let category = ENPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])
        let categorySecond = ENPushNotificationActionCategory(identifierName: "category1", buttonActions: [actionOne, actionTwo])
        let categoryThird = ENPushNotificationActionCategory(identifierName: "category2", buttonActions: [actionOne, actionTwo,actionThree,actionFour,actionFive])
        
        XCTAssertEqual(category.identifier, "category")
        XCTAssertEqual(category.actions, [actionOne, actionTwo])
        
        XCTAssertEqual(categorySecond.identifier, "category1")
        XCTAssertEqual(categorySecond.actions, [actionOne, actionTwo])
        
        XCTAssertEqual(categoryThird.identifier, "category2")
        XCTAssertEqual(categoryThird.actions, [actionOne, actionTwo,actionThree,actionFour,actionFive])
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
