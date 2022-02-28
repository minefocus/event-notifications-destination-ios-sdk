Pod::Spec.new do |s|

    s.name                  = 'ENPushDestination'
    s.version               = '0.0.1'
    s.summary               = 'iOS Destination SDK for IBM Cloud Event Notifications service'
    s.license               = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.homepage              = 'https://github.com/IBM/event-notifications-destination-ios-sdk'
    s.authors               = 'IBM Cloud Event Notifications.'
    
    s.module_name           = 'ENPushDestination'
    s.ios.deployment_target = '10.0'
    s.source                = { :git => 'https://github.com/IBM/event-notifications-destination-ios-sdk.git', :tag => s.version.to_s }
  
    s.dependency 'IBMSwiftSDKCore', '~> 1.2.1'

    s.source_files          = 'ENPushDestination/**/*.swift'
    s.swift_version         = ['4.2', '5.0', '5.1', '5.5']
    s.static_framework        = true
    s.cocoapods_version       = '>= 1.10.0'

  end