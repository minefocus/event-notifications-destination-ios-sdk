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
//  ENTagModel.swift
//  ENPush
//
//  Created by Anantha Krishnan K G on 10/02/22.
//

import Foundation

/**
 ENTagModel represents the Device-Tag subscription payload.
 */
public struct ENTagModel: Codable {
    public let deviceId, tagName: String
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case tagName = "tag_name"
    }
}
