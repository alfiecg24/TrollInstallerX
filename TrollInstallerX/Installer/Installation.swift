//
//  Installation.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import Foundation

let fileManager = FileManager.default
let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path
let kernelPath = docsDir + "/kernelcache"


func checkForMDCUnsandbox() -> Bool {
    return fileManager.fileExists(atPath: docsDir + "/full_disk_access_sandbox_token.txt")
}

func getKernel(_ device: Device) -> Bool {
    if !fileManager.fileExists(atPath: kernelPath) {
        if MacDirtyCow.supports(device) && checkForMDCUnsandbox() {
            let fd = open(docsDir + "/full_disk_access_sandbox_token.txt", O_RDONLY)
            if fd > 0 {
                let tokenData = get_NSString_from_file(fd)
                sandbox_extension_consume(tokenData)
                Logger.log("Copying kernelcache")
                let path = get_kernelcache_path()
                do {
                    try fileManager.copyItem(atPath: path!, toPath: kernelPath)
                    return true
                } catch {
                    Logger.log("Failed to copy kernelcache", type: .error)
                    NSLog("Failed to copy kernelcache - \(error)")
                }
            }
        }
        Logger.log("Downloading kernel")
        if !grab_kernelcache(kernelPath) {
            Logger.log("Failed to download kernel", type: .error)
            return false
        }
    }
    
    return true
}

func cleanup_private_preboot() -> Bool {
    // Remove /private/preboot/tmp
    let fileManager = FileManager.default
    do {
        try fileManager.removeItem(atPath: "/private/preboot/tmp")
    } catch let e {
        print("Failed to remove /private/preboot/tmp! \(e.localizedDescription)")
        return false
    }
    return true
}


func doInstall(_ device: Device) async {
    
    let exploit = physpuppet
    
    let iOS14 = !device.version.supportsMajorVersion(15)
    let supportsFullPhysRW = (device.isArm64e && device.version >= Version(major: 15, minor: 2)) || (!device.isArm64e && device.version.supportsMajorVersion(15))
    
    if !iOS14 {
        if !(getKernel(device)) {
            Logger.log("Failed to get kernel", type: .error)
            return
        }
    }
    
    Logger.log("Gathering kernel information")
    if !initialise_kernel_info(kernelPath, iOS14) {
        Logger.log("Failed to patchfind kernel", type: .error)
        return
    }
    
    Logger.log("Exploiting kernel (\(exploit.name))")
    if !exploit.initialise!() {
        Logger.log("Failed to exploit the kernel", type: .error)
        return
    }
    Logger.log("Successfully exploited the kernel", type: .success)
    post_kernel_exploit(iOS14)
    
    if supportsFullPhysRW {
        if device.isArm64e {
            Logger.log("Bypassing PPL (\(dmaFail.name))")
            if !dmaFail.initialise!() {
                Logger.log("Failed to bypass PPL", type: .error)
                return
            }
            Logger.log("Successfully bypassed PPL", type: .success)
        }
        
        if #available(iOS 16, *) {
            libjailbreak_kalloc_pt_init()
        }
        
        if !build_physrw_primitive() {
            Logger.log("Failed to build physical R/W primitive", type: .error)
            return
        }
        
        if device.isArm64e {
            Logger.log("Deinitialising PPL bypass (\(dmaFail.name))")
            if !dmaFail.deinitialise!() {
                Logger.log("Failed to deinitialise \(dmaFail.name)", type: .error)
                return
            }
        }
        
        Logger.log("Deinitialising kernel exploit (\(exploit.name))")
        if !exploit.deinitialise!() {
            Logger.log("Failed to deinitialise \(exploit.name)", type: .error)
            return
        }
        
        Logger.log("Unsandboxing")
        if !unsandbox() {
            Logger.log("Failed to unsandbox", type: .error)
            return
        }
        
        Logger.log("Escalating privileges")
        if !get_root_pplrw() {
            Logger.log("Failed to escalate privileges", type: .error)
            return
        }
        if !platformise() {
            Logger.log("Failed to platformise", type: .error)
            return
        }
    } else {
        Logger.log("Unsandboxing and escalating privileges")
        if !get_root_krw(iOS14) {
            Logger.log("Failed to unsandbox and escalate privileges", type: .error)
            return
        }
        Logger.log("Deinitialising kernel exploit (\(exploit.name))")
        if !exploit.deinitialise!() {
            Logger.log("Failed to deinitialise \(exploit.name)", type: .error)
            return
        }
    }

    remount_private_preboot()
    if !fileManager.fileExists(atPath: "/private/preboot/tmp/trollstorehelper") && !fileManager.fileExists(atPath: "/private/preboot/tmp/TrollStore.tar") {
        Logger.log("Extracting TrollStore.tar")
        if !extract_trollstore() {
            Logger.log("Failed to extract TrollStore.tar", type: .error)
            return
        }
    }
    
    Logger.log("Installing TrollStore")
    if !install_trollstore(Bundle.main.bundlePath + "/TrollStore.tar") {
        Logger.log("Failed to install TrollStore", type: .error)
        return
    }
    
    if !cleanup_private_preboot() {
        Logger.log("Failed to clean up /private/preboot", type: .error)
        return
    }
    
    if !supportsFullPhysRW {
        if !drop_root_krw(iOS14) {
            Logger.log("Failed to drop root privileges", type: .error)
            return
        }
    }
    
    Logger.log("Successfully installed TrollStore", type: .success)
    
    return
}
