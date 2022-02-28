
[![Build Status](https://travis-ci.com/IBM/event-notifications-destination-ios-sdk.svg?token=eW5FVD71iyte6tTby8gr&branch=main)](https://travis-ci.com/IBM/event-notifications-destination-ios-sdk)


# iOS destination SDK for IBM Cloud Event Notifications service Version 0.0.1
iOS destination client library to interact with various [IBM Cloud Event Notifications Service](https://cloud.ibm.com/apidocs?category=event-notifications).

Disclaimer: this SDK is being released initially as a **pre-release** version.
Changes might occur which impact applications that use this SDK.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  * [Gradle](#gradle)
- [Using the SDK](#using-the-sdk)
- [Questions](#questions)
- [Issues](#issues)
- [Open source @ IBM](#open-source--ibm)
- [Contributing](#contributing)
- [License](#license)

<!-- tocstop -->

## Overview

The IBM Cloud Event Notifications Service iOS destination SDK allows developers to register for APNS destiantion of Event Notifications service in IBM cloud.

Service Name | Artifact Coordinates
--- | ---
[Event Notifications Service](https://cloud.ibm.com/apidocs/event-notifications) | ENPushDestination:0.0.1

## Prerequisites

[ibm-cloud-onboarding]: https://cloud.ibm.com/registration

* An [IBM Cloud][ibm-cloud-onboarding] account.
* An Event Notifications Instance
* An IAM API key to allow the SDK to access your account. Create one [here](https://cloud.ibm.com/iam/apikeys).
* Xcode 9.3+
* Swift 4.2+
* iOS 10.0+

## Installation
The current version of this SDK is: 0.0.1

To use the Event Notifications iOS destination SDK, define a dependency that contains the artifact coordinates (group id, artifact id and version) for the service, like this:


### Cocoapods
```ruby
use_frameworks!

target 'MyApp' do
    pod 'ENPushDestination', '~> 0.0.1'
end
```

### Carthage

To install `ENPushDestination` using Carthage, add the following to your Cartfile.

```ruby
  github "IBM/event-notifications-destination-ios-sdk" ~> 0.0.1
```

Then run the following command to build the dependencies and frameworks:

```ruby
$ carthage update --platform iOS
```

### Swift Package Manager

Add the following to your `Package.swift` file to identify ENPushDestination as a dependency. The package manager will clone ENPushDestination when you build your project with swift build.
```ruby
dependencies: [
    .package(url: "https://github.com/IBM/event-notifications-destination-ios-sdk", from: "0.0.1")
]
```

## Using the SDK

SDK Methods to consume

- [Initialize SDK](#initialize-sdk)
    - [Initialize SDK](#initialize-sdk)
- [Register for notifications](#register-for-notifications)
	- [Receiving notifications](#receiving-notifications)
	- [Unregistering from notifications](#unregistering-from-notifications)
- [Event Notifications destination tags subscriptions](#event-notifications-destination-tags-subscriptions)
	- [Subscribe to tags](#subscribe-to-tags)
	- [Retrieve subscribed tags](#retrieve-subscribed-tags)
	- [Unsubscribe from tags](#unsubscribe-from-tags)
- [Receiving push notifications on iOS devices](#receiving-push-notifications-on-ios-devices)
- [Notification options](#notification-options)
	- [Interactive notifications](#interactive-notifications)
	- [Adding custom DeviceId for registration](#adding-custom-deviceid-for-registration)
	- [Enabling rich media notifications](#enabling-rich-media-notifications)

## Installation

### Initialize SDK

Complete the following steps to enable iOS applications to receive notifications.

1. Add the `import` statements in your `.swift` file.
		
   ```swift
   import ENPushDestination
   ```

2. Initialize the ENPushDestination SDK

	```swift

	let instanceGUID = "<instance_guid>>";
	let destinationID = "<instance_destination_id>";
	let apiKey = "<instance_apikey>";

	let enPush = ENPush.sharedInstance
	enPush.setCloudRegion(region: .usSouth)
	enPush.initialize(instanceGUID, destinationID, apiKey)
	```

	- region : Region of the Event Notifications Instance. eg; `Region.usSouth`

## Register for notifications

Use the `ENPush.registerDevice()` API to register the device with iOS destination in Event Notifications service. 

The following options are supported:

- Register without userId:
	
	```swift
	/**Register iOS devices*/
    enPush.registerWithDeviceToken(deviceToken: "<apns-device-token>") { response, statusCode, error in

        print(response?.id ?? "")

    }
	```

- Register with UserId. For `userId` based notification, the register method will accept one more parameter - `userId`.

	```swift
	/**Register iOS devices*/
    enPush.registerWithDeviceToken(deviceToken: "<apns-device-token>", withUserId: "userId") { response, statusCode, error in
            
        print(response?.id ?? "")

    }
	```
The userId is used to pass the unique userId value for registering for Event notifications.

### Unregistering from notifications

Use the following code snippets to un-register from Event Notifications.

```swift
enPush.unregisterDevice { response, statusCode, error in
    /**.....*/  
}
```
>**Note**: To unregister from the `UserId` based registration, you have to call the registration method. See the `Register without userId option` in [Register for notifications](#register-for-notifications).

## Event Notifications destination tags subscriptions

### Subscribe to tags

The `subscribe` API will subscribe the device for a given tag. After the device is subscribed to a particular tag, the device can receive notifications that are sent for that tag. 

Add the following code snippet to your iOS mobile application to subscribe to a list of tags.

```swift
// Subscribe to the given tag
enPush.subscribeToTags(tagName: "<tag_name>") { response, statusCode, error in
	/**.....*/  
});
```

### Retrieve subscribed tags

The `retrieveSubscriptionsWithCompletionHandler` API will return the list of tags to which the device is subscribed. Use the following code snippets in the mobile application to get the subscription list.

```swift
// Get a list of tags that to which the device is subscribed.
enPush.retrieveSubscriptionsWithCompletionHandler { response, statusCode, error in
    /**.....*/   
}
```

### Unsubscribe from tags

The `unsubscribeFromTags` API will remove the device subscription from the list tags. Use the following code snippets to allow your devices to get unsubscribe from a tag.

```swift
// unsubscibe from the given tag ,that to which the device is subscribed.
enPush.unsubscribeFromTags(tagName: "<tag_name>") { response, statusCode, error in
  /**.....*/   
}
```

### Receiving push notifications on iOS devices
To receive push notifications on iOS devices, add the following Swift method to the appDelegate.swift of your application:

```swift
 func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

	//UserInfo dictionary will contain data sent from the server
 }
```

## Notification options

The following notification options are supported.


### Interactive notifications

1. To enable interactive push notifications, the notification action parameters must be passed in as part of the notification object. The following is a sample code to enable interactive notifications:

```swift
let actionOne = ENPushNotificationAction(identifierName: "FIRST", buttonTitle: "Accept", isAuthenticationRequired: false, defineActivationMode: .foreground)
    
let actionTwo = ENPushNotificationAction(identifierName: "SECOND", buttonTitle: "Reject", isAuthenticationRequired: false, defineActivationMode: .destructive)
    
let category = ENPushNotificationActionCategory(identifierName: "category", buttonActions: [actionOne, actionTwo])

let notificationOptions = ENPushClientOptions()
notificationOptions.setInteractiveNotificationCategories(categoryName: [category])
enPush.initialize(instanceGUID, destinationID, apiKey, notificationOptions)

```

2. Implement the callback method on AppDelegate.swift:

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
	switch response.actionIdentifier {
		case "Accept":
		print("Clicked Accept")
		case "Reject":
		print("Clicked Reject")
		default:
	}
	completionHandler()
 }
```
	
This callback method is invoked when user clicks the action button. The implementation of this method must perform tasks associated with the specified identifier and execute the block in the completionHandler parameter.

### Adding custom DeviceId for registration

To send `DeviceId` use the `setDeviceId` method of `ENPushClientOptions` class.

```swift
	let options = ENPushClientOptions();
	options.setDeviceId(deviceId: "YOUR_DEVICE_ID");
```

>**Note**: Remember to keep custom DeviceId `unique` for each device.


### Enabling rich media notifications

Rich media notifications are supported on iOS 10 or later. To receive rich media notifications, implement UNNotificationServiceExtension. The extension will intercept and handle the rich media notification.

In the didReceive() method of your service extension, add the following code to retrieve the rich push notification content.

```swift
override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
	self.contentHandler = contentHandler
	bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    ENPushRichPushNotificationOptions.didReceive(request, withContentHandler: contentHandler)
}
```

## Questions

If you are having difficulties using this SDK or have a question about the IBM Cloud services,
please ask a question at
[Stack Overflow](http://stackoverflow.com/questions/ask?tags=ibm-cloud).

## Issues
If you encounter an issue with the project, you are welcome to submit a
[bug report](https://github.com/IBM/event-notifications-destination-ios-sdk/issues).
Before that, please search for similar issues. It's possible that someone has already reported the problem.

## Open source @ IBM
Find more open source projects on the [IBM Github Page](http://ibm.github.io/)

## Contributing
See [CONTRIBUTING](CONTRIBUTING.md).

## License

The IBM Cloud Event Notifications Service iOS destination SDK is released under the Apache 2.0 license.
The license's full text can be found in [LICENSE](LICENSE).
