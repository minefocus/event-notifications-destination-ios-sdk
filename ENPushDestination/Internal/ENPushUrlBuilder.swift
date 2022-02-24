/**
 (C) Copyright IBM Corp. 2021.

 Licensed under the Apache License, Version 2.0 (the "License")
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
//  ENPushUrlBuilder.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 08/02/22.
//

import Foundation

internal class ENPushUrlBuilder: NSObject {
    
    internal let FORWARDSLASH = "/"
    internal let ENPUSH = "event-notifications"
    internal let V1 = "v1"
    internal let INSTANCES = "instances"
    internal let DESTINATIONS = "destinations"
    internal let AMPERSAND = "&"
    internal let QUESTIONMARK = "?"
    internal let EQUALTO = "="
    internal let SUBSCRIPTIONS = "tag_subscriptions"
    internal let TAGS = "tags"
    internal let DEVICES = "devices"
    internal let MESSAGES = "messages"

    internal let TAGNAME = "tag_name"
    internal let DEVICEID = "device_id"
    internal let defaultProtocol = "https"
    
    internal let HOST = "cloud.ibm.com"
    internal let HTTPS_SCHEME = "https://"
    internal let DOT = "."

    internal final var pwUrl_ = ""
    internal final var reWritedomain = ""
    
//    let DEFAULT_IAM_DEV_STAGE_URL = "https://iam.test.cloud.ibm.com/identity/token"

    /**
     Init method
     - Parameter instanceId: instanceId of the Event Notifications service
     - Parameter destinationId: destinationId of the Event Notifications service
    */
    init(instanceId: String, destinationId: String) {
        
        super.init()
        
        if !ENPush.overrideServerHost.isEmpty {
            pwUrl_ += ENPush.overrideServerHost
            reWritedomain = ENPush.overrideServerHost
        } else {
            pwUrl_ += HTTPS_SCHEME
            pwUrl_ += ENPush.sharedInstance.getCloudRegion()
            pwUrl_ += DOT
            pwUrl_ += ENPUSH
            pwUrl_ += DOT
            pwUrl_ += HOST
        }
        pwUrl_ += FORWARDSLASH
        pwUrl_ += ENPUSH
        pwUrl_ += FORWARDSLASH
        pwUrl_ += V1
        pwUrl_ += FORWARDSLASH
        pwUrl_ += INSTANCES
        pwUrl_ += FORWARDSLASH
        pwUrl_ += instanceId
        pwUrl_ += FORWARDSLASH
        pwUrl_ += DESTINATIONS
        pwUrl_ += FORWARDSLASH
        pwUrl_ += destinationId
        pwUrl_ += FORWARDSLASH
    }
   
    /**
     Get the device url.
     - Returns device API url.
     */
    func getDevicesUrl() -> String {
        
        return getCollectionUrl(collectionName: DEVICES)
    }

    /**
     Get device url.
     - Parameter deviceId : deviceId for the Event Notifications service
     - Returns return the device ID url.
    */
    func getDeviceIdUrl(deviceId: String) -> String {
        
        var deviceIdUrl: String = getDevicesUrl()
        deviceIdUrl += FORWARDSLASH
        deviceIdUrl += deviceId
        return deviceIdUrl
    }
    
    /**
     Get subscriptions url
     - Returns return subscription url.
     */
    func getSubscriptionsUrl() -> String {
        
        return getCollectionUrl(collectionName: SUBSCRIPTIONS)
    }
    
    /**
     Get subscriptions url
     - Parameter deviceId: deviceId for the Event Notifications service
     - Parameter tagName: tagName for the subscription
     -  return subscriptions url
    */
    func getAvailableSubscriptionsUrl(deviceId: String, tagName: String = "") -> String {
        
        var subscriptionURL = getCollectionUrl(collectionName: SUBSCRIPTIONS)
        subscriptionURL += QUESTIONMARK
        subscriptionURL += "\(DEVICEID)=\(deviceId)"
        if !tagName.isEmpty {
            subscriptionURL += AMPERSAND
            subscriptionURL += "\(TAGNAME)=\(tagName)"
        }
        return subscriptionURL
    }
    
    /**
      Get unregister url.
     - Parameter deviceId: deviceId for the Event Notifications service
     - Returns unregister url.
    */
    func getUnregisterUrl (deviceId: String) -> String {
        
        var deviceUnregisterUrl: String = getDevicesUrl()
        deviceUnregisterUrl += FORWARDSLASH
        deviceUnregisterUrl += deviceId
        return deviceUnregisterUrl
    }
    
    /**
     Get rewrite domain
    - Returns rewrite domain url
     */
    func getRewriteDomain() -> String {

        return reWritedomain
    }
    
    /// Return the base url + path
    internal func getCollectionUrl (collectionName: String) -> String {
        
        var collectionUrl: String = pwUrl_
        collectionUrl += collectionName
        
        return collectionUrl
    }
    
    /// Return base headers
    func getHeader() -> [String: String] {
        let userAgent = "\(ENPUSH_SDK_NAME)/\(ENPUSH_SDK_VERSION)"
        return [ENPUSH_USER_AGENT: userAgent, ENPUSH_CONTENT_TYPE_KEY: ENPUSH_CONTENT_TYPE_JSON]
        
    }
}
