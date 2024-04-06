//
//  Device.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import SwiftUI

enum CPUFamily {
    // These also remain as-is for X verrsions (e.g. A10 and A10X are the same family)
    case Unknown
    case A8
    case A9
    case A10
    case A11
    case A12
    case A13
    case A14
    case A15
    case A16
}

struct Device {
    let version: Version
    let isArm64e: Bool
    let supportsOTA: Bool
    let isSupported: Bool
    let isOnSupported17Beta: Bool
    var cpuFamily: CPUFamily
    
    init() {
        self.version = Version(UIDevice.current.systemVersion)
        
        // Check if arm64e
        var cpusubtype: Int32 = 0
        var len = MemoryLayout.size(ofValue: cpusubtype)
        sysctlbyname("hw.cpusubtype", &cpusubtype, &len, nil, 0)
        self.isArm64e = cpusubtype == CPU_SUBTYPE_ARM64E
        
        // Check if device supports TrollHelperOTA
        if self.isArm64e {
            supportsOTA = self.version < Version("15.7")
        } else {
            supportsOTA = self.version >= Version("15.0") && self.version < Version("15.5")
        }
        
        // Set the CPU family (for checking dmaFail compatibility)
        var deviceCPU = 0
        len = MemoryLayout.size(ofValue: deviceCPU);
        sysctlbyname("hw.cpufamily", &deviceCPU, &len, nil, 0);
        
        // Set the SoC
        switch deviceCPU {
        case 0x2C91A47E:
            self.cpuFamily = .A8
        case 0x92FB37C8:
            self.cpuFamily = .A9
        case 0x67CEEE93:
            self.cpuFamily = .A10
        case 0xE81E7EF6:
            self.cpuFamily = .A11
        case 0x07D34B9F:
            self.cpuFamily = .A12
        case 0x462504D2:
            self.cpuFamily = .A13
        case 0x1B588BB3:
            self.cpuFamily = .A14
        case 0xDA33D83D:
            self.cpuFamily = .A15
        case 0x8765EDEA:
            self.cpuFamily = .A16
        default:
            self.cpuFamily = .Unknown
        }
        
        // Set the CPU family (for checking dmaFail compatibility)
        len = 256;
        var buildNumber = [CChar](repeating: 0, count: len)
        sysctlbyname("kern.osversion", &buildNumber, &len, nil, 0);
        let buildNumberStr = String(cString: buildNumber)
        
        if buildNumberStr == "21A5248v" // Beta 1
        || buildNumberStr == "21A5268h" // Beta 2
        || buildNumberStr == "21A5277j" // Beta 3
        || buildNumberStr == "21A5291h" // Beta 4
        || buildNumberStr == "21A5291j" // Beta 4 (re-release)
        {
            self.isOnSupported17Beta = true
        } else {
            self.isOnSupported17Beta = false
        }
        
        var isM2 = false
        
        let registryEntry = IORegistryEntryFromPath(mach_port_t(MACH_PORT_NULL), "IODeviceTree:/chosen")
        if let bmHash = IORegistryEntryCreateCFProperty(registryEntry, "chip-id" as CFString, kCFAllocatorDefault, 0) {
            if let bootManifestHashData = bmHash.takeRetainedValue() as? Data {
                let cpid: Int = bootManifestHashData.withUnsafeBytes { $0.pointee }
                isM2 = cpid == 0x8112
            }
        }
        
        if self.cpuFamily == .A8 {
            isSupported = self.version < Version("15.2")
        } else {
            isSupported = (self.version <= Version("16.6.1")) || (self.isOnSupported17Beta && !((self.cpuFamily == .A15 || isM2) || self.cpuFamily == .A16))
        }
    }
    
    var modelIdentifier: String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    var supportsDirectInstall: Bool {
        if !self.isArm64e { return true }
        if self.cpuFamily == .A15 || self.cpuFamily == .A16 {
            return self.version < Version("16.5.1")
        } else {
            return self.version < Version("16.6")
        }
    }
}
