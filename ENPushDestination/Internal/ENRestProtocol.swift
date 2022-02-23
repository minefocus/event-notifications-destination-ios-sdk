
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
//  ENRestProtocol.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 14/02/22.
//

import Foundation
import IBMSwiftSDKCore

protocol ENRestProtocol {
    func responseObject<T:Decodable>(completionHandler: @escaping (T?, Int, String) -> Void)
    func initRest(
        apikey: String,
        method: String,
        url: String,
        headerParameters: [String: String],
        queryItems: [URLQueryItem]?,
        messageBody: Data?)
}

class ENRestDefault: ENRestProtocol {
    
    private var session = URLSession(configuration: URLSessionConfiguration.default)
    var request: RestRequest?
    let DEFAULT_IAM_DEV_STAGE_URL = "https://iam.test.cloud.ibm.com/identity/token"

    @objc public func initRest(
        apikey: String,
        method: String,
        url: String,
        headerParameters: [String: String],
        queryItems: [URLQueryItem]? = nil,
        messageBody: Data? = nil) {
            
            var iamAuthenticator: IAMAuthenticator
            
            if (!ENPush.overrideServerHost.isEmpty) {
                iamAuthenticator = IAMAuthenticator(apiKey: apikey, url: DEFAULT_IAM_DEV_STAGE_URL)
            } else {
                iamAuthenticator = IAMAuthenticator(apiKey: apikey)
            }
            
            self.request = RestRequest(session: self.session, authenticator: iamAuthenticator, errorResponseDecoder: self.errorResponseDecoder, method: method, url: url, headerParameters: headerParameters, queryItems: queryItems, messageBody: messageBody)
        }
    
    func responseObject<T:Decodable>(completionHandler: @escaping (T?, Int, String) -> Void) {
        
        
        request?.responseObject { (response:RestResponse<T>?, error:RestError?) in
            
            guard error == nil else {
                completionHandler(nil, response?.statusCode ?? ENPUSH_NETWORK_ERROR, error.debugDescription)
                return
            }
            
            guard response != nil, let statusCode = response?.statusCode else {
                completionHandler(nil,response?.statusCode ?? ENPUSH_NETWORK_ERROR, "Empty response")
                return
            }
            completionHandler(response?.result, statusCode, "")
        }
    }
    
   private func responseDecoder(response:RestResponse<ENDeviceModel>?, error:RestError?) -> Int  {
        
        guard error == nil else {
            
            switch error {
            case .http(let statusCode, _, _):
                if statusCode == ENPUSH_RESOURCE_NOT_FOUND_ERROR {
                    return statusCode!
                }
                break
            default :
                ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while verifying previous registration - Error is: \(error?.errorDescription ?? "")")
            }
            return ENPUSH_NETWORK_ERROR
        }
        
        guard response != nil, let statusCode = response?.statusCode else {
            ENLogger.sharedInstance.logger(logLevel: .error, message: "Error while verifying previous registration - Error is: Empty response")
            return ENPUSH_NETWORK_ERROR

        }
        return statusCode
    }
    
    /**
     Use the HTTP response and data received by the Tone Analyzer service to extract
     information about the error that occurred.
     - parameter data: Raw data returned by the service that may represent an error.
     - parameter response: the URL response returned by the service.
     */
    private func errorResponseDecoder(data: Data, response: HTTPURLResponse) -> RestError {
        
        let statusCode = response.statusCode
        var errorMessage: String?
        var metadata = [String: Any]()
        
        do {
            let json = try JSON.decoder.decode([String: JSON].self, from: data)
            metadata["response"] = json
            if case let .some(.array(errors)) = json["errors"],
               case let .some(.object(error)) = errors.first,
               case let .some(.string(message)) = error["message"] {
                errorMessage = message
            } else if case let .some(.string(message)) = json["error"] {
                errorMessage = message
            } else if case let .some(.string(message)) = json["message"] {
                errorMessage = message
            } else {
                errorMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            }
        } catch {
            metadata["response"] = data
            errorMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
        }
        
        return RestError.http(statusCode: statusCode, message: errorMessage, metadata: metadata)
    }
    
}
