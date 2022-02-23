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
//  ENPushClientOptions.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 08/02/22.
//

import Foundation

/**
 ENPushClientOptions set options for push notifications like Buttons, Categories etc.
 */
public class ENPushClientOptions: NSObject {
    
    // MARK: - Properties
    
    /// Category value - An array of Push categories.
    var category: [ENPushNotificationActionCategory]
    
    /// Device for registrations. This is a userinput value. If not given the default deviceId will be used.
    var deviceId: String
    
    /// Push variables  - A Key value pair.
    var pushVariables: [String: String]
    
    // MARK: Initializers
    
    /**
     Initialze Method .
     */
    public override init() {
        self.category = []
        self.deviceId = ""
        self.pushVariables = [:]
    }
    
    /**
     Initialze Method .
     - parameter categoryName: An array of `ENPushNotificationActionCategory`.
     */
    public init (categoryName category: [ENPushNotificationActionCategory]) {
        self.category = category
        self.deviceId = ""
        self.pushVariables = [:]
    }
    
    /**
     Initialze Method .
     - parameter categoryName: An array of `ENPushNotificationActionCategory`.
     - parameter deviceId: Custom deviceId for the device registering for push notifications.
     */
    public init (categoryName category: [ENPushNotificationActionCategory], deviceId: String) {
        self.category = category
        self.deviceId = deviceId
        self.pushVariables = [:]
    }
    
    /**
     set DeviceId Method
     
     - parameter withDeviceId:  (Optional) The DeviceId for applications.
     */
    public func setDeviceId(deviceId: String) {
        self.deviceId = deviceId
        
    }
    
    /**
     set Interactive Notification Categories Method
     
     - parameter categoryName: An array of `ENPushNotificationActionCategory`.
     */
    public func setInteractiveNotificationCategories(categoryName category: [ENPushNotificationActionCategory]) {
        self.category = category
    }
    
    /**
     set Push Variables for template based push Notification.
     
     - parameter pushVariables: a [String:String] values.
     */
    public func  setPushVariables(pushVariables variables: [String: String]) {
        self.pushVariables = variables
    }
}
