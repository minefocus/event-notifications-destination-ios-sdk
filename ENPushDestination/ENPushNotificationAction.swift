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
//  ENPushNotificationAction.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 08/02/22.
//

import Foundation
import UIKit

/**
  Creates action objects for iOS push notifications
 */
public class ENPushNotificationAction: NSObject {
    
    // MARK: - Properties
    
    /// Unique identifier for the ENPushNotificationAction.
    var identifier: String
    
    /// Title for the ENPushNotificationAction.
    var title: String
    
    /// Bool value for authenticationRequired for the UIMutableUserNotificationAction.
    var authenticationRequired: Bool?
    var activationMode: UNNotificationActionOptions
    
    // MARK: Initializers
    
    /**
     Initialze Method -  Deprecated.
     
     - parameter identifierName: identifier name for your actions.
     - parameter title: Title for your actions.
     - parameter authenticationRequired: Authenticationenbling option for your actions.
     - parameter activationMode: Notification action option for your actions.
     */
    public init (identifierName identifier: String, buttonTitle title: String,
                 isAuthenticationRequired authenticationRequired: Bool,
                 defineActivationMode activationMode: UNNotificationActionOptions) {
        self.identifier = identifier
        self.title = title
        self.authenticationRequired = authenticationRequired
        self.activationMode = activationMode
    }
    
}
