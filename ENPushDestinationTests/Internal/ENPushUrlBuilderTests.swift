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
//  ENPushUrlBuilderTests.swift
//  ENPushTests
//
//  Created by Anantha Krishnan K G on 14/02/22.
//

import XCTest
@testable import ENPushDestination

class ENPushUrlBuilderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ENPush.overrideServerHost = ""
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ENPush.overrideServerHost = ""
    }

    func testENPushUrlBuilder() throws {
        
        let mockInstanceId = "hfyjg-5867-ghkjh"
        let mockDestinationId = "786-957687-kljhjksd"
        ENPush.sharedInstance.setCloudRegion(region: .usSouth)
        
        let sut = ENPushUrlBuilder(instanceId: mockInstanceId, destinationId: mockDestinationId)
        
        XCTAssertNotNil(sut, "ENPushUrlBuilder object should be valid")
        
        let expectedBaseUrl = "https://us-south.event-notifications.cloud.ibm.com/event-notifications/v1/instances/\(mockInstanceId)/destinations/\(mockDestinationId)"
        
        var expectedUrl = expectedBaseUrl + "/devices"
        var resultUrl = sut.getDevicesUrl()
        XCTAssertEqual(expectedUrl, resultUrl, "Device url should be valid")
        
        
        let deviceId = "dummyDeviceId"
        expectedUrl = expectedBaseUrl + "/devices/" + deviceId
        resultUrl = sut.getDeviceIdUrl(deviceId: deviceId)
        XCTAssertEqual(expectedUrl, resultUrl, "DeviceID url should be valid")
                
        expectedUrl = expectedBaseUrl + "/tag_subscriptions"
        resultUrl = sut.getSubscriptionsUrl()
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        expectedUrl = expectedBaseUrl + "/tag_subscriptions?device_id=" + deviceId
        resultUrl = sut.getAvailableSubscriptionsUrl(deviceId: deviceId)
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        
        let tagName = "tag_name"
        expectedUrl = expectedBaseUrl + "/tag_subscriptions?device_id=" + deviceId + "&tag_name=" + tagName
        resultUrl = sut.getAvailableSubscriptionsUrl(deviceId: deviceId, tagName: tagName)
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        
        expectedUrl = expectedBaseUrl + "/devices/" + deviceId
        resultUrl = sut.getUnregisterUrl(deviceId: deviceId)
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        XCTAssertEqual(sut.getRewriteDomain(), "")
        
        let headers = sut.getHeader()
        XCTAssertEqual(headers.count, 2)
        
        XCTAssertTrue(headers.keys.contains(ENPUSH_USER_AGENT), "User Agent header should be there")
    }
    
    
    func testENPushUrlBuilderWithCustomBase() throws {
        
        let mockInstanceId = "hfyjg-5867-ghkjh"
        let mockDestinationId = "786-957687-kljhjksd"
        ENPush.sharedInstance.setCloudRegion(region: .usSouth)
        let customBase = "https://CustomBaseTest.com"
        ENPush.overrideServerHost = customBase
        
        let sut = ENPushUrlBuilder(instanceId: mockInstanceId, destinationId: mockDestinationId)
        
        XCTAssertNotNil(sut, "ENPushUrlBuilder object should be valid")
        
        let expectedBaseUrl = customBase + "/event-notifications/v1/instances/\(mockInstanceId)/destinations/\(mockDestinationId)"
        
        var expectedUrl = expectedBaseUrl + "/devices"
        var resultUrl = sut.getDevicesUrl()
        XCTAssertEqual(expectedUrl, resultUrl, "Device url should be valid")
        
        
        let deviceId = "dummyDeviceId"
        expectedUrl = expectedBaseUrl + "/devices/" + deviceId
        resultUrl = sut.getDeviceIdUrl(deviceId: deviceId)
        XCTAssertEqual(expectedUrl, resultUrl, "DeviceID url should be valid")
                
        expectedUrl = expectedBaseUrl + "/tag_subscriptions"
        resultUrl = sut.getSubscriptionsUrl()
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        expectedUrl = expectedBaseUrl + "/tag_subscriptions?device_id=" + deviceId
        resultUrl = sut.getAvailableSubscriptionsUrl(deviceId: deviceId)
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        
        let tagName = "tag_name"
        expectedUrl = expectedBaseUrl + "/tag_subscriptions?device_id=" + deviceId + "&tag_name=" + tagName
        resultUrl = sut.getAvailableSubscriptionsUrl(deviceId: deviceId, tagName: tagName)
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        
        expectedUrl = expectedBaseUrl + "/devices/" + deviceId
        resultUrl = sut.getUnregisterUrl(deviceId: deviceId)
        XCTAssertEqual(expectedUrl, resultUrl, "Device subscription url should be valid")
        
        XCTAssertEqual(sut.getRewriteDomain(), customBase)
        
        let headers = sut.getHeader()
        XCTAssertEqual(headers.count, 2)
        
        XCTAssertTrue(headers.keys.contains(ENPUSH_USER_AGENT), "User Agent header should be there")
    }
    
    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
