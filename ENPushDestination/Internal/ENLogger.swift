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
//  ENLogger.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 09/02/22.
//

import Foundation

/// Debug level for the SDK
public enum ENLogLevel: String {
    case info = "Info"
    case debug = "Debug"
}

// Log value type
enum ENLogType: String {
    case info = "Info"
    case debug = "Debug"
    case fatal = "fatal"
    case error = "error"
    case warn = "warn"
}

/// Class for logs in ENPush
class ENLogger {
    
    public static let sharedInstance = ENLogger()
    private init() {}

    
    let INTERNAL_PREFIX = "eventnotifications.sdk."
    var level = ENLogLevel.info;
    var delegate: LogListener?
    
    func setLevel(_ newlevel: ENLogLevel) {
        level = newlevel
    }
    
    func logger(logLevel: ENLogType, message: String, caller: String = #function, timeStamp: String = Date().description, object: Dictionary<String, Any>? = nil) {
        if level == .debug {
            print("\(INTERNAL_PREFIX):\(caller) -> \(timeStamp)-\(logLevel) : \(message) , \(object?.description ?? "")")
            
        }
        delegate?.logger(logLevel: logLevel.rawValue, message: message, caller: caller, timeStamp: timeStamp, object: object)
    }
    
}

public protocol LogListener {
    func logger(logLevel: String, message: String, caller: String, timeStamp: String, object: Dictionary<String, Any>?)
}
