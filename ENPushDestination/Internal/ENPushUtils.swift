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
//  ENPushUtils.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 09/02/22.
//

import Foundation
import UIKit

/**
 Utils class for `ENPush`
 */
open class ENPushUtils: NSObject {
    
    static var loggerMessage: String = ""
    private static var account_attr: String {
        if let bundleID = Bundle.main.bundleIdentifier {
            return bundleID.appending("ENPushUtils-Secrets")
        }
        return ""
    }
    
    @objc dynamic open class func saveValueToStorage(_ value: Data?, key: String) {
        
        guard let data = value else {return}
        
        loggerMessage = ("Saving value to Storage with Key: \(key)")
        ENLogger.sharedInstance.logger(logLevel: .debug, message: loggerMessage)
        
        let query = [
            kSecValueData: data,
            kSecAttrService: key,
            kSecAttrAccount: account_attr,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            let query = [
                kSecAttrService: key,
                kSecAttrAccount: account_attr,
                kSecClass: kSecClassGenericPassword
            ] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            SecItemUpdate(query, attributesToUpdate)
        }
        
    }
    
    @objc dynamic open class func getValueFromStorage(key: String) -> Data? {
        
        let query = [
            kSecAttrService: key,
            kSecAttrAccount: account_attr,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        loggerMessage = ("Getting value for Storage Key: \(key)")
        ENLogger.sharedInstance.logger(logLevel: .debug, message: loggerMessage)
        return (result as? Data)
    }
    
    /** Check for the paramterised notifications*/
    class func checkTemplateNotifications(_ body: String) -> String {
        
        let regex = "\\{\\{.*?\\}\\}"
        var text = body
        
        guard let hasVariables = UserDefaults.standard.value(forKey: HAS_ENPUSH_VARIABLES) as?  Bool else {
            return text
        }
        
        if !hasVariables {
            return text
        }
        
        guard let optionVariables = getValueFromStorage(key: ENPUSH_VARIABLES)?.getDictionary() as? [String: String] else { return text }
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            let resultMap = results.compactMap {
                Range($0.range, in: text).map {
                    String(text[$0])
                }
            }
            
            for val in resultMap {
                var temp = val
                temp = temp.replacingOccurrences(of: "{{", with: "", options: NSString.CompareOptions.literal, range: nil)
                temp = temp.replacingOccurrences(of: "}}", with: "", options: NSString.CompareOptions.literal, range: nil)
                temp = temp.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                if let templateValue = optionVariables[temp] {
                    text = text.replacingOccurrences(of: val, with: templateValue)
                }
            }
            return text
            
        } catch {
            return text
        }
    }
}

extension String {
    func getData() -> Data {
        return Data(self.utf8)
    }
}

extension Data {
    func getString() -> String {
        String(decoding: self, as: UTF8.self)
    }
    
    func getDictionary() -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
        } catch {}
        return nil
    }
}

extension Dictionary {
    func getData() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {}
        return nil
    }
}
