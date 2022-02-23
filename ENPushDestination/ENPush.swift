
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

//  ENPush.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 08/02/22.
//



import Foundation
import UIKit

public class ENPush: NSObject {
    
    // MARK: Properties (Private)
    private var notificationOptions : ENPushClientOptions?
    
    // MARK: Properties (Public)
    let enNotificationName = UIApplication.didBecomeActiveNotification
    let applicationBGstate =  UIApplication.State.background
    
    // used to test in test zone and dev zone
    public static var overrideServerHost = "";
    
    // MARK: - Properties
    
    /**
     The region where your IBM Cloud service is hosted.
     */
    public enum Region: String {
        
        /**
         The southern United States IBM Cloud region.
         */
        case usSouth = "us-south"
        
        /**
         The United Kingdom IBM Cloud region.
         */
        case london = "eu-gb"
        
        /**
         The Sydney IBM Cloud region.
         */
        case sydney = "au-syd"
        
    }
    
    /// This singleton should be used for all `ENPush` activity.
    public static let sharedInstance = ENPush()
    
    private override init() {}
    
    // Specifies the IBM Cloud push clientSecret value
    public private(set) var guid: String?
    public private(set) var destinationId: String?
    public private(set) var apikey: String?
    public var delegate:ENPushObserver?
    var networkRequest:ENRestProtocol = ENRestDefault()

    private var deviceId: String?
    private var region: Region?
    
    // Notification Count
    private var notificationcount:Int = 0
    private var isInitialized = false;
    
    
    /**
     Set the cloud region.
     - parameter region: Event Notifications cloud region.
     */
    public func setCloudRegion(region: Region) {
        self.region = region
    }
    
    /**
     Get the cloud region.
     - Returns region: Event Notifications cloud region.
     */
    public func getCloudRegion() -> String {
        self.region?.rawValue ?? ""
    }
    
    /**
     Set the logger level for SDK. Default value is `debug`.
     - Parameters level: Log level value ie; debug or info.
     */
    public func setLoggerLevel(_ level : ENLogLevel) {
        ENLogger.sharedInstance.setLevel(level)
    }
    
    /**
     Set the logger listener from SDK.
     - Parameters listener: LogListener delegate.
     */
    public func setLogListener(_ listener: LogListener) {
        ENLogger.sharedInstance.delegate = listener
    }
    
    /**
     ENPush Initialisation method with GUID and destinationId.
     - parameter guid: The unique ID of the Event Notifications service instance that the application must connect to.
     - parameter destinationId: DestinationID from the Event Notifications service.
     - parameter apikey:  API Key from the Event Notifications service.
     */
    public func initialize(_ guid: String, _ destinationId: String, _ apikey: String) {
        
        if validateString(object: guid) &&
            validateString(object: destinationId) &&
            validateString(object: apikey) {
            
            self.guid = guid
            self.destinationId = destinationId
            self.apikey = apikey
            
            ENPushUtils.saveValueToStorage(guid.getData(), key: ENPUSH_APP_GUID)
            ENPushUtils.saveValueToStorage(destinationId.getData(), key: ENPUSH_DESTINATION_ID)
            ENPushUtils.saveValueToStorage(apikey.getData(), key: ENPUSH_APIKEY)
            
            isInitialized = true;
            self.deviceId = ""
            
            UserDefaults.standard.set(false, forKey: HAS_ENPUSH_VARIABLES)
            UserDefaults.standard.synchronize()
            
            initPushCenter(UNUserNotificationCenter.current())
            
        } else {
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration -  invalid / missing credentials")
            self.delegate?.onChangePermission(status: false)
            
        }
    }
    
    /**
     ENPush Initialisation method with GUID and destinationId.
     - parameter guid: The unique ID of the Event Notifications service instance that the application must connect to.
     - parameter destinationId: DestinationID from the Event Notifications service.
     - parameter apikey:  API Key from the Event Notifications service.
     - parameter options:  ENPushClientOptions for the Push Notifications.
     */
    public func initialize (_ guid: String, _ destinationId: String, _ apikey: String, _ options: ENPushClientOptions) {
        
        if validateString(object: guid) &&
            validateString(object: destinationId) &&
            validateString(object: apikey) {
            
            self.guid = guid
            self.destinationId = destinationId
            self.apikey = apikey
            
            ENPushUtils.saveValueToStorage(guid.getData(), key: ENPUSH_APP_GUID)
            ENPushUtils.saveValueToStorage(destinationId.getData(), key: ENPUSH_DESTINATION_ID)
            ENPushUtils.saveValueToStorage(apikey.getData(), key: ENPUSH_APIKEY)
            
            isInitialized = true;
            self.deviceId = options.deviceId
            let category : [ENPushNotificationActionCategory] = options.category
            
            self.notificationOptions = options
            
            if !options.pushVariables.isEmpty && options.pushVariables.count > 0 {
                ENPushUtils.saveValueToStorage( options.pushVariables.getData(), key: ENPUSH_VARIABLES)
                UserDefaults.standard.set(true, forKey: HAS_ENPUSH_VARIABLES)
            } else {
                UserDefaults.standard.set(false, forKey: HAS_ENPUSH_VARIABLES)
            }
            UserDefaults.standard.synchronize()
            
            let center = UNUserNotificationCenter.current()
            
            var notifCategory = Set<UNNotificationCategory>();
            
            for singleCategory in category {
                
                let categoryFirst : ENPushNotificationActionCategory = singleCategory
                let pushCategoryIdentifier : String = categoryFirst.identifier
                let pushNotificationAction : [ENPushNotificationAction] = categoryFirst.actions
                var pushActionsArray = [UNNotificationAction]()
                
                for actionButton in pushNotificationAction {
                    
                    let newActionButton : ENPushNotificationAction = actionButton
                    let options:UNNotificationActionOptions = actionButton.activationMode
                    
                    let addButton = UNNotificationAction(identifier: newActionButton.identifier, title: newActionButton.title, options: [options])
                    pushActionsArray.append(addButton)
                }
                
                let responseCategory = UNNotificationCategory(identifier: pushCategoryIdentifier, actions: pushActionsArray, intentIdentifiers: [])
                notifCategory.insert(responseCategory)
            }
            
            if !notifCategory.isEmpty {
                center.setNotificationCategories(notifCategory)
            }
            self.initPushCenter(center)
            
        } else {
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration -  invalid / missing credentials")
            self.delegate?.onChangePermission(status: false)
        }
    }
    
    // MARK: Methods (Public)
    
    /**
     
     This Methode used to register the client device to the IBM Cloud Event Notifications service. This is the normal registration, without userId.
     
     Call this methode after successfully registering for remote push notification in the Apple Push
     Notification Service .
     
     - Parameter deviceToken: This is the response we get from the push registartion in APNs.
     - Parameter withUserId: This is the userId value.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    public func registerWithDeviceToken(deviceToken:Data , withUserId:String, completionHandler: @escaping(_ response:ENDeviceModel?, _ statusCode:Int?, _ error:String) -> Void) {
        
        if (isInitialized) {
            
            if (validateString(object: withUserId)) {
                registerForDestination(deviceToken: deviceToken, userId: withUserId, completionHandler: completionHandler)
            } else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration - Provide a valid userId value")
                
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue , "Error while registration - Provide a valid userId value")
            }
        } else {
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration - ENPush is not initialized")
            completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue , "Error while registration - ENPush is not initialized")
        }
        
    }
    
    /**
     This Methode used to register the client device to the IBM Cloud Event Notifications service. This is the normal registration, without userId.
     
     Call this methode after successfully registering for remote push notification in the Apple Push
     Notification Service .
     
     - Parameter deviceToken: This is the response we get from the push registartion in APNs.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    public func registerWithDeviceToken (deviceToken:Data, completionHandler: @escaping(_ response:ENDeviceModel?, _ statusCode:Int?, _ error:String) -> Void) {
        if (isInitialized) {
            registerForDestination(deviceToken: deviceToken, completionHandler: completionHandler)
        } else {
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration - ENPush is not initialized")
            completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue , "Error while registration - ENPush is not initialized")
        }
    }
    
    /**
     This Method used to Subscribe to a Tag in the IBM Event notificaitons service APNs destination.
     
     This methode will return the list of subscribed tags. If you pass the tags that are not present in the IBM Cloud App it will be classified under the TAGS NOT FOUND section in the response.
     
     - parameter tagName: the tag name.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (ENTagModel), StatusCode (Int) and error (string).
     */
    public func subscribeToTags (tagName:String, completionHandler: @escaping (_ response:ENTagModel?, _ statusCode:Int?, _ error:String) -> Void) {
        
        ENLogger.sharedInstance.logger(logLevel: .debug, message:"Entering: subscribeToTags." )
        
        let devId = self.getDeviceID()
        
        if !checkForCredentials() {
            
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while subscribing to tag - Error is: push is not initialized")
            completionHandler(nil, ENPushErrorvalues.ENPushTagSubscriptionError.rawValue , "Error while subscribing to tag - Error is: push is not initialized")
            return
            
        }
        
        let urlBuilder = ENPushUrlBuilder(instanceId: self.guid!, destinationId: self.destinationId!)
        let resourceURL:String = urlBuilder.getSubscriptionsUrl()
        let headers = urlBuilder.getHeader()
        
//        var iamAuthenticator: IAMAuthenticator
//
//        if (validateString(object: ENPush.overrideServerHost)) {
//            iamAuthenticator = IAMAuthenticator(apiKey: self.apikey!, url: urlBuilder.DEFAULT_IAM_DEV_STAGE_URL)
//        } else {
//            iamAuthenticator = IAMAuthenticator(apiKey: self.apikey!)
//        }
//
        let dataString = "{\"\(ENPUSH_TAG_NAME)\":\"\(tagName)\", \"\(ENPUSH_DEVICE_ID)\":\"\(devId)\"}"
        let data = dataString.data(using: .utf8)
//
//        let request = RestRequest(session: self.session,
//                                  authenticator: iamAuthenticator,
//                              errorResponseDecoder: self.errorResponseDecoder,
//                                  method: "POST",
//                                  url: resourceURL,
//                                  headerParameters: headers,
//                                  queryItems: nil,
//                                  messageBody: data)
        
        networkRequest.initRest(apikey: self.apikey!, method: "POST", url: resourceURL, headerParameters: headers, queryItems: nil, messageBody: data)
        
        networkRequest.responseObject {[weak self] (response:ENTagModel?, statusCode: Int, error:String)  in
            
        
       // request.responseObject { [weak self] (response:RestResponse<ENTagModel>?, error:RestError?) in
            guard self != nil else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while subscribed to tag - Error is: Lost class reference")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while subscribed to tag - Error is: Lost class reference")

                return
            }
            guard error.isEmpty else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while subscribed to tag - Error is: \(error.debugDescription)")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while registration - Error is: \(error.debugDescription)")
                return
            }
            
            guard let response = response else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while subscribed to tag - Error is: Empty response")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while subscribed to tag - Error is: Empty response")
                return
            }
            
            if statusCode >= 200 && statusCode <= 299 {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Successfully subscribed to tag - Response is:  \(String(describing: response))")
                completionHandler(response, statusCode, "")
            } else {
                ENLogger.sharedInstance.logger(logLevel: .error, message:  "Error while subscribing to tag - Error code is:: \(statusCode) and error is: \(String(describing: response))")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue, "Error while subscribing to tag - Error code is: \(statusCode) and error is: \(String(describing: response))")
            }
        }
    }
    
    /**
     This Methode used to Retrieve the Subscribed Tags in the IBM Event notificaitons service APNs destination.
     
     This methode will return the list of subscribed tags.
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableArray), StatusCode (Int) and error (string).
     */
    public func retrieveSubscriptionsWithCompletionHandler  (completionHandler: @escaping (_ response:ENSubscriptionsModel?, _ statusCode:Int?, _ error:String) -> Void) {
        
        ENLogger.sharedInstance.logger(logLevel: .debug, message: "Entering retrieveSubscriptionsWithCompletitionHandler.")
        
        let devId = self.getDeviceID()
        
        if !checkForCredentials() {
            
            ENLogger.sharedInstance.logger(logLevel: .debug, message: "Error while retrieving subscriptions - Error is: push is not initialized")
            completionHandler(nil, ENPushErrorvalues.ENPushTagSubscriptionError.rawValue , "Error while retrieving subscriptions - Error is: push is not initialized")
            return
            
        }
        
        let urlBuilder = ENPushUrlBuilder(instanceId: self.guid!, destinationId: self.destinationId!)
        let resourceURL:String = urlBuilder.getAvailableSubscriptionsUrl(deviceId: devId)
        let headers = urlBuilder.getHeader()
        
//        var iamAuthenticator: IAMAuthenticator
//
//        if (validateString(object: ENPush.overrideServerHost)) {
//            iamAuthenticator = IAMAuthenticator(apiKey: self.apikey!, url: urlBuilder.DEFAULT_IAM_DEV_STAGE_URL)
//        } else {
//            iamAuthenticator = IAMAuthenticator(apiKey: self.apikey!)
//        }
//
//
//        let request = RestRequest(session: session,
//                                  authenticator: iamAuthenticator,
//                                  errorResponseDecoder: errorResponseDecoder,
//                                  method: "GET",
//                                  url: resourceURL,
//                                  headerParameters: headers,
//                                  queryItems: nil,
//                                  messageBody: nil)
        
        networkRequest.initRest(apikey: self.apikey!, method: "GET", url: resourceURL, headerParameters: headers, queryItems: nil, messageBody: nil)
        networkRequest.responseObject { [weak self] (response:ENSubscriptionsModel?, statusCode: Int, error:String)in
            
        
        //request.responseObject { [weak self] (response:RestResponse<ENSubscriptionsModel>?, error:RestError?) in
            guard self != nil else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while retrieving subscriptions - Error is: Lost class reference")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while retrieving subscriptions - Error is: Lost class reference")

                return
            }
            guard error.isEmpty else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while retrieving subscriptions - Error is: \(error.debugDescription)")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while retrieving subscriptions - Error is: \(error.debugDescription)")
                return
            }
            
            guard let response = response else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while retrieving subscriptions - Error is: Empty response")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while retrieving subscriptions - Error is: Empty response")
                return
            }
            
            if statusCode >= 200 && statusCode <= 299 {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Subscription retrieved successfully - Response is:  \(String(describing: response))")
                completionHandler(response, statusCode, "")
            } else {
                ENLogger.sharedInstance.logger(logLevel: .error, message:  "Error while retrieving subscriptions - Error code is:: \(statusCode) and error is: \(String(describing: response))")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue, "Error while retrieving subscriptions - Error code is: \(statusCode) and error is: \(String(describing: response))")
            }
        }
    }
    
    /**
     This Methode used to Unsubscribe from the Subscribed Tags in the IBM Event notificaitons service APNs destination.
     
     This methode will return the details of Unsubscription status.
     
     - parameter tagName: the tag name.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (NSMutableDictionary), StatusCode (Int) and error (string).
     */
    public func unsubscribeFromTags(tagName:String, completionHandler: @escaping (_ response:String?, _ statusCode:Int?, _ error:String) -> Void) {
        
        ENLogger.sharedInstance.logger(logLevel: .error, message: "Entering: unsubscribeFromTags")
        
        let devId = self.getDeviceID()
        
        if !checkForCredentials() {
            
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unsubscribing from tags - Error is: push is not initialized")
            completionHandler("", ENPushErrorvalues.ENPushTagUnsubscriptionError.rawValue , "Error while unsubscribing from tags - Error is: push is not initialized")
            return
            
        }
        
        let urlBuilder = ENPushUrlBuilder(instanceId: self.guid!, destinationId: self.destinationId!)
        let resourceURL:String = urlBuilder.getAvailableSubscriptionsUrl(deviceId: devId, tagName: tagName)
        let headers = urlBuilder.getHeader()
        
//        var iamAuthenticator: IAMAuthenticator
//
//        if (validateString(object: ENPush.overrideServerHost)) {
//            iamAuthenticator = IAMAuthenticator(apiKey: self.apikey!, url: urlBuilder.DEFAULT_IAM_DEV_STAGE_URL)
//        } else {
//            iamAuthenticator = IAMAuthenticator(apiKey: self.apikey!)
//        }
//
//
//        let request = RestRequest(session: session,
//                                  authenticator: iamAuthenticator,
//                                  errorResponseDecoder: errorResponseDecoder,
//                                  method: "DELETE",
//                                  url: resourceURL,
//                                  headerParameters: headers,
//                                  queryItems: nil,
//                                  messageBody: nil)
        
        networkRequest.initRest(apikey: self.apikey!, method: "DELETE", url: resourceURL, headerParameters: headers, queryItems: nil, messageBody: nil)
        networkRequest.responseObject { [weak self] (response:ENSubscriptionsModel?, statusCode: Int, error:String) in
            
        //}
        
       // request.responseObject { [weak self] (response:RestResponse<ENSubscriptionsModel>?, error:RestError?) in
            guard self != nil else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unsubscribing from tags - Error is: Lost class reference")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while unsubscribing from tags - Error is: Lost class reference")

                return
            }
            guard error.isEmpty else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unsubscribing from tags - Error is: \(error.debugDescription)")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while unsubscribing from tags - Error is: \(error.debugDescription)")
                return
            }
            
            guard let response = response else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unsubscribing from tags - Error is: Empty response")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while unsubscribing from tags - Error is: Empty response")
                return
            }
            
            if statusCode >= 200 && statusCode <= 299 {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Successfully unsubscribed from tags - Response is: \(String(describing: response))")
                completionHandler(String(describing: response), statusCode, "")
            } else {
                ENLogger.sharedInstance.logger(logLevel: .error, message:  "Error while unsubscribing from tags - Error code is:: \(statusCode) and error is: \(String(describing: response))")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue, "Error while unsubscribing from tags - Error code is: \(statusCode) and error is: \(String(describing: response))")
            }
        }
    }
    
    /**
     
     This Methode used to UnRegister the client App from the IBM Event notificaitons service APNs destination.
     
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    public func unregisterDevice(completionHandler: @escaping (_ response:String?, _ statusCode:Int?, _ error:String) -> Void) {
        
        ENLogger.sharedInstance.logger(logLevel: .error, message: "Entering unregisterDevice.")
        let devId = self.getDeviceID()
        
        if !checkForCredentials() {
            
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unregistering device - Error is: push is not initialized")
            completionHandler("", ENPushErrorvalues.ENPushTagUnsubscriptionError.rawValue , "Error while unregistering device - Error is: push is not initialized")
            return
            
        }
        
        let urlBuilder = ENPushUrlBuilder(instanceId: self.guid!, destinationId: self.destinationId!)
        let resourceURL:String = urlBuilder.getUnregisterUrl(deviceId: devId)
        
        let headers = urlBuilder.getHeader()
        
        networkRequest.initRest(apikey: self.apikey!, method: "DELETE", url: resourceURL, headerParameters: headers, queryItems: nil, messageBody: nil)
        
        
        networkRequest.responseObject { [weak self] (response:ENSubscriptionsModel?, statusCode: Int, error:String) in

            guard self != nil else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unregistering device - Error is: Lost class reference")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while unregistering device - Error is: Lost class reference")

                return
            }
            guard error.isEmpty else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unregistering device - Error is: \(error.debugDescription)")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while unregistering device - Error is: \(error.debugDescription)")
                return
            }
            
//            guard response != nil, let statusCode = response?.statusCode else {
            guard let response = response else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while unregistering device - Error is: Empty response")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while unregistering device - Error is: Empty response")
                return
            }
            
            if statusCode >= 200 && statusCode <= 299 {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Successfully unregistered the device")
                completionHandler(String(describing: response), statusCode, "")
            } else {
                ENLogger.sharedInstance.logger(logLevel: .error, message:  "Error while unregistering device - Error code is:: \(statusCode) and error is: \(String(describing: response))")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue, "Error while unregistering device - Error code is: \(statusCode) and error is: \(String(describing: response))")
            }
        }
    }
    
    /**
     This Methode used to handle the template based push notifications.
     - Parameter userInfo: Push Notification userInfo object.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String) and, error (string).
     */
    public func didReciveBMSPushNotification (userInfo: [AnyHashable : Any], completionHandler: @escaping (_ response:String?, _ error:String) -> Void) {
        
        
        //let payload = userInfo as NSDictionary
        
        
        guard let hasTemplate = userInfo["has-template"] as? Int  else {
            completionHandler("", "Not a template based push Notification")
            return  }
        
        if hasTemplate == 1 {
            
            let payload = userInfo as NSDictionary
            var additionalPaylaod: [AnyHashable : Any] = [:]
            var alertBody: String = ""
            var title: String = ""
            var subTitle: String = ""
            var categoryIdentifier: String = ""
            var sound: String = ""
            var attachmentURL:String = ""
            var badge:NSNumber = 0
            
            if let additionalJson = payload.value(forKey: "payload") as? [AnyHashable : Any], additionalJson.count != 0 {
                additionalPaylaod = additionalJson
            }
            
            guard let templateAps = payload.value(forKey: "template") as? NSDictionary, templateAps.count > 0 else {
                completionHandler("", "Get Template Json - Failed to get template based push notification")
                return
            }
            
            guard  let alertJson = templateAps.value(forKey: "alert") as? NSDictionary else {
                completionHandler("", "Get Alert Body - Failed to get template based push notification")
                return
            }
            
            if let message = alertJson.value(forKey: "body") as? String {
                alertBody = ENPushUtils.checkTemplateNotifications(message);
            }
            
            if let titleValue = alertJson.value(forKey: "title") as? String {
                title = titleValue
            }
            
            if let subTitleValue = alertJson.value(forKey: "subTitle") as? String {
                subTitle = subTitleValue
            }
            
            if let soundValue = alertJson.value(forKey: "sound") as? String {
                sound = soundValue
            }
            
            if let attachmentUrlValue = payload.value(forKey: "attachment-url") as? String {
                attachmentURL = attachmentUrlValue
            }
            if let badgeValue = templateAps.value(forKey: "badge") as? NSNumber {
                badge = badgeValue
            }
            if let categoryValue = templateAps.value(forKey: "category") as? String {
                categoryIdentifier = categoryValue
            }
            
            if #available(iOS 10.0, *) {
                let localPush = ENLocalPushNotification(body: alertBody, title: title, subtitle: subTitle, sound: sound, badge: badge, categoryIdentifier: categoryIdentifier, attachments: attachmentURL, userInfo: additionalPaylaod)
                localPush.showENPushNotification()
                completionHandler("", "Template push success")
            } else {
                completionHandler("", "Template based push is not supporte dbelow iOS10")
            }
        } else {
            completionHandler("", "Not a template based push Notification")
            return
        }
    }
    // MARK: Methods (Internal)
    
    /**
     Register to the Event Notifications service destination.
     - Parameter deviceToken: This is the response we get from the push registartion in APNs.
     - Parameter userId: This is the userId value.
     - Parameter completionHandler: The closure that will be called when this request finishes. The response will contain response (String), StatusCode (Int) and error (string).
     */
    fileprivate func registerForDestination(deviceToken:Data , userId:String = "", completionHandler: @escaping(ENDeviceModel?,Int?, String) -> Void) {
        
        let devId = self.getDeviceID()
        ENPushUtils.saveValueToStorage(devId.getData(), key: ENPUSH_DEVICE_ID)
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(token)
        
        if !checkForCredentials() {
            
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration - Error is: SDK is not initialized")
            completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue , "Error while registration - Error is: SDK is not initialized")
            return
        }
        
        let urlBuilder = ENPushUrlBuilder(instanceId: self.guid!, destinationId: self.destinationId!)
        let resourceURL:String = urlBuilder.getDeviceIdUrl(deviceId: devId)
        let headers = urlBuilder.getHeader()
        
        ENLogger.sharedInstance.logger(logLevel: .debug, message: "Verifying previous device registration.")

        
        networkRequest.initRest(apikey: self.apikey!, method: "GET", url: resourceURL, headerParameters: headers, queryItems: nil, messageBody: nil)

        
        networkRequest.responseObject { [weak self] (response: ENDeviceModel?, statusCode: Int, error: String) in
                    
            guard let self = self else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while verifying previous registration - Error is: Lost class reference")
                completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while verifying previous registration - Error is: Lost class reference")

                return
            }
            
            //let statusCode = self.responseDecoder(response: response, error: error)
            
            var resourceURL:String = ""
            let headers = urlBuilder.getHeader()
            var data:Data?
            var method = "POST"

            if statusCode == ENPUSH_RESOURCE_NOT_FOUND_ERROR {
                
                ENLogger.sharedInstance.logger(logLevel: .debug, message:  "Device is not registered before.  Registering for the first time.")
                resourceURL = urlBuilder.getDevicesUrl()
                if userId.isEmpty {
                    let dataString =  "{\"\(ENPUSH_DEVICE_ID)\": \"\(devId)\", \"\(ENPUSH_TOKEN)\": \"\(token)\", \"\(ENPUSH_PLATFORM)\": \"A\"}"
                    
                    data = dataString.data(using: .utf8)
                } else {
                    let dataString =  "{\"\(ENPUSH_DEVICE_ID)\": \"\(devId)\", \"\(ENPUSH_TOKEN)\": \"\(token)\", \"\(ENPUSH_PLATFORM)\": \"A\", \"\(ENPUSH_USER_ID)\": \"\(userId)\"}"
                    data = dataString.data(using: .utf8)
                }
                
            } else if statusCode == 200 {
                
                ENLogger.sharedInstance.logger(logLevel: .debug, message:  "Device is already registered.")
              //  let respDevice = response?.result
                
                let rToken = response?.token ?? ""
                let rDevId = response?.id ?? ""
                let userIdresp = response?.userID ?? ""
                
                if ((rToken.compare(token)) != ComparisonResult.orderedSame) ||
                    (!(userId.isEmpty) && (userIdresp.compare(userId) != ComparisonResult.orderedSame)) ||
                    (devId.compare(rDevId) != ComparisonResult.orderedSame) {
                    
                    ENLogger.sharedInstance.logger(logLevel: .error, message: "Device token or DeviceId has changed. Sending update registration request.")
                    resourceURL = urlBuilder.getDeviceIdUrl(deviceId: devId)
                    method =  "PUT"
                    if userId.isEmpty {
                        let dataString =  "{\"\(ENPUSH_DEVICE_ID)\": \"\(devId)\", \"\(ENPUSH_TOKEN)\": \"\(token)\", \"\(ENPUSH_PLATFORM)\": \"A\"}"
                        data = dataString.data(using: .utf8)
                    } else {
                        let dataString =  "{\"\(ENPUSH_DEVICE_ID)\": \"\(devId)\", \"\(ENPUSH_TOKEN)\": \"\(token)\", \"\(ENPUSH_PLATFORM)\": \"A\", \"\(ENPUSH_USER_ID)\": \"\(userId)\"}"
                        data = dataString.data(using: .utf8)
                    }
                    
                } else {
                    ENLogger.sharedInstance.logger(logLevel: .error, message: "Device is already registered and device registration parameters not changed.")
                    completionHandler(response, statusCode, "")
                    return
                }
                
            } else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while verifying previous registration - Error is: Unknown status")
                completionHandler(nil, statusCode, "Error while verifying previous registration - Error is: Unknown status")
                return
            }
            
            
            self.networkRequest.initRest(apikey: self.apikey!, method: method, url: resourceURL, headerParameters: headers, queryItems: nil, messageBody: data)
            
            self.networkRequest.responseObject { [weak self] (response:ENDeviceModel?, statusCode: Int, error: String) in
   
                guard self != nil else {
                    ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration - Error is: Lost class reference")
                    completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while verifying previous registration - Error is: Lost class reference")

                    return
                }
                guard error.isEmpty else {
                    ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration - Error is: \(error.debugDescription)")
                    completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while registration - Error is: \(error.debugDescription)")
                    return
                }
                
//                guard response != nil, let statusCode = response?.statusCode else {
                guard let response = response else {
                    ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registration - Error is: Empty response")
                    completionHandler(nil, ENPushErrorvalues.ENPushRegistrationVerificationError.rawValue , "Error while registration - Error is: Empty response")
                    return
                }
                
                if statusCode >= 200 && statusCode <= 299 {
                    ENLogger.sharedInstance.logger(logLevel: .error, message: "Response of device registration - Response is: \(response) registered")
                    completionHandler(response, statusCode, "")
                } else {
                    ENLogger.sharedInstance.logger(logLevel: .error, message:  "Error during device registration - Error code is: \(statusCode) and error is: \(String(describing: response))")
                    completionHandler(nil, ENPushErrorvalues.ENPushRegistrationError.rawValue, "Error during device registration - Error code is: \(statusCode) and error is: \(String(describing: response))")
                }
            }
            
        }

    }
    
    /**
     validate the object for empty values or null
     - Parameter object: input string to be checked.
     */
    fileprivate func validateString(object:String) -> Bool{
        if (object.isEmpty || object == "") {
            return false;
        }
        return true
    }
    
    /**
     Get deviceID for the ios device.
     - Returns : valid UUID string.
     */
    fileprivate func getDeviceID() -> String{
        var devId = String()
        if ((self.deviceId == nil) || (self.deviceId?.isEmpty)!) {
            // Generate new ID
            devId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        }else{
            devId = self.deviceId!
        }
        return devId
    }
    
    /**
     initialise push notification with given UNUserNotificationCenter
     - Parameters center: object of UNUserNotificationCenter
     */
    @objc func initPushCenter(_ center: UNUserNotificationCenter?) {
        
        guard let center = center else {
            self.delegate?.onChangePermission(status: false)
            return
        }
        center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if(granted) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                self.delegate?.onChangePermission(status: true)
            } else {
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while registering with APNS server :  \(String(describing: error))")
                self.delegate?.onChangePermission(status: false)
                self.checkStatusChange()
            }
        })
    }
    
    /**
     Check the credentials are availble for use.
     - Returns return `bool`.
     */
    fileprivate func checkForCredentials() -> Bool {
        
        self.guid = ENPushUtils.getValueFromStorage(key: ENPUSH_APP_GUID)?.getString()
        self.destinationId = ENPushUtils.getValueFromStorage(key: ENPUSH_DESTINATION_ID)?.getString()
        self.apikey = ENPushUtils.getValueFromStorage(key: ENPUSH_APIKEY)?.getString()
        
        if(self.guid == "" || self.destinationId == "" || self.apikey == "") {
            return false
        }
        return true
    }
    
    /**
     Check for the Push notification status.
     */
    fileprivate func checkStatusChange() {
        
        if(UserDefaults.standard.object(forKey: ENPUSH_APP_INSTALL) != nil) {
            statusChangeHeloper()
        } else {
            UserDefaults.standard.set(true, forKey: ENPUSH_APP_INSTALL)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.addObserver(forName: enNotificationName, object: nil, queue: OperationQueue.main) { (notifiction) in
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
                    self?.statusChangeHeloper()
                }
            }
        }
    }
    /// Helper method for the Push notifications status change.
    fileprivate func statusChangeHeloper() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                ENLogger.sharedInstance.logger(logLevel: .info, message: "Push Enabled")
                self.delegate?.onChangePermission(status: true)
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                break
            default:
                ENLogger.sharedInstance.logger(logLevel: .info, message: "Push Disabled")
                self.delegate?.onChangePermission(status: false)
            }
        }
    }
    
}
