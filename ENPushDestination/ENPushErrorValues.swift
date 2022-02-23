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
//  ENPushErrorValues.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 09/02/22.
//

import Foundation

public enum ENPushErrorvalues: Int {
    
    /// - ENPushErrorInternalError: Denotes the Internal Server Error occured.
    case ENPushErrorInternalError = 1
    
    /// - ENPushRegistrationVerificationError: Denotes the Previous Push registration Error.
    case ENPushRegistrationVerificationError = 3
    
    /// - ENPushRegistrationError: Denotes the First Time Push registration Error.
    case ENPushRegistrationError = 4
    
    /// - ENPushRegistrationUpdateError: Denotes the Device updation Error.
    case ENPushRegistrationUpdateError = 5
    
    /// - ENPushRetrieveSubscriptionError: Denotes the Subscribed tags retrieval error.
    case ENPushRetrieveSubscriptionError = 6
    
    /// - ENPushTagSubscriptionError: Denotes the Tag Subscription error.
    case ENPushTagSubscriptionError = 8
    
    /// - ENPushTagUnsubscriptionError: Denotes the tag Unsubscription error.
    case ENPushTagUnsubscriptionError = 9
    
    /// - BMSPushUnregitrationError: Denotes the Push Unregistration error.
    case BMSPushUnregitrationError = 10
}
