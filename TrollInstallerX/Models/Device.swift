//
//  Device.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

struct Device {
    let version: Version
//    let install: Install
    
    var isArm64e: Bool {
        var cpusubtype: Int32 = 0
        var len = MemoryLayout.size(ofValue: cpusubtype)
        guard sysctlbyname("hw.cpusubtype", &cpusubtype, &len, nil, 0) == 0 else { return false }
        return cpusubtype == CPU_SUBTYPE_ARM64E
    }
    
}

func initDevice() -> Device {
    var systemVersion = UIDevice.current.systemVersion
    print("System version: \(systemVersion)")
    return Device(version: Version(systemVersion))
}
