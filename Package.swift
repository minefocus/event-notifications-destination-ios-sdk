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
 
import PackageDescription

let package = Package(
    name: "ENPushDestination",
    products: [
        .library(name: "ENPushDestination", targets: ["ENPushDestination"]),
    ],
    dependencies: [
        .package(url: "https://github.com/IBM/swift-sdk-core.git", from: "1.2.1"),
    ],
    targets: [
        .target(name: "ENPushDestination", dependencies: ["IBMSwiftSDKCore"], path: "ENPushDestination/Internal"),
        .testTarget(name: "ENPushDestinationTests", dependencies: ["ENPushDestination"]),
    ]
)
