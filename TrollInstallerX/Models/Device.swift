//
//  Device.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

struct Device {
    let version: Version
    
    var isArm64e: Bool {
        var cpusubtype: Int32 = 0
        var len = MemoryLayout.size(ofValue: cpusubtype)
        guard sysctlbyname("hw.cpusubtype", &cpusubtype, &len, nil, 0) == 0 else { return false }
        return cpusubtype == CPU_SUBTYPE_ARM64E
    }
    
    var supportsOTA: Bool {
        if self.isArm64e {
            return self.version < Version("15.7")
        } else {
            return self.version >= Version("15.0") && self.version < Version("15.5")
        }
    }
    
}

func initDevice() -> Device {
    let systemVersion = UIDevice.current.systemVersion
    print("System version: \(systemVersion)")
    return Device(version: Version(systemVersion))
}
