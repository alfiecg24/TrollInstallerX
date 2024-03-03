//
//  AppleDB.swift
//  TrollInstallerX
//
//  Created by Alfie on 10/02/2024.
//

import Foundation
import SwiftUI

// https://api.appledb.dev/ios/PLATFORM;BUILDID.json
let baseURL = "https://api.appledb.dev/ios/"

func getOSStr() -> String {
    return UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
}

func getBuildNumber() -> String {
    guard let buildVersion = MGCopyAnswer("BuildVersion" as CFString) else {
        return ""
    }

    let buildNumberString = String(describing: buildVersion.takeRetainedValue())
    return buildNumberString
}

func getHWModel() -> String {
    guard let buildVersion = MGCopyAnswer("HWModelStr" as CFString) else {
        return ""
    }

    let buildNumberString = String(describing: buildVersion.takeRetainedValue())
    return buildNumberString
}

func getMachineName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let machineName = machineMirror.children
        .compactMap { $0.value as? Int8 }
        .prefix(while: { $0 != 0 })
        .map { Character(UnicodeScalar(UInt8($0))) }
        .map { String($0) }
        .joined()
    
    return machineName
}


func getAPIURL() -> URL {
    return URL(string: baseURL + getOSStr() + ";" + getBuildNumber() + ".json")!
}
