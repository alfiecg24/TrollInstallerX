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

func asyncUnsandboxMDC() async {
    await Task {
        MacDirtyCow.unsandbox!()
    }.value
}

func getKernel(_ device: Device) async -> Bool {
    if !fileManager.fileExists(atPath: kernelPath) {
        if MacDirtyCow.supports(device) {
            Logger.log("Unsandboxing using MacDirtyCow")
            await asyncUnsandboxMDC()
            let path = get_kernelcache_path()
            do {
                try fileManager.copyItem(atPath: path!, toPath: kernelPath)
                return true
            } catch {
                Logger.log("Failed to copy kernelcache", type: .error)
                NSLog("Failed to copy kernelcache - \(error)")
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
    
    if !(await getKernel(device)) {
        Logger.log("Failed to get kernel", type: .error)
        return
    }
    
    Logger.log("Gathering kernel information")
    if !initialise_kernel_info(kernelPath) {
        Logger.log("Failed to patchfind kernel", type: .error)
        return
    }
    
//    Logger.log("Exploiting kernel (\(landa.name))")
//    if !landa.initialise!() {
//        Logger.log("Failed to exploit the kernel", type: .error)
//        return
//    }
//    Logger.log("Successfully exploited the kernel", type: .success)
//    post_kernel_exploit()
//    
//    if device.isArm64e {
//        Logger.log("Bypassing PPL (\(dmaFail.name))")
//        if !dmaFail.initialise!() {
//            Logger.log("Failed to bypass PPL", type: .error)
//            return
//        }
//        Logger.log("Successfully bypassed PPL", type: .success)
//    }
//    
//    if #available(iOS 16, *) {
//        libjailbreak_kalloc_pt_init()
//    }
//    
//    if !build_physrw_primitive() {
//        Logger.log("Failed to build physical R/W primitive", type: .error)
//        return
//    }
//    
//    if device.isArm64e {
//        Logger.log("Deinitialising PPL bypass (\(dmaFail.name))")
//        if !dmaFail.deinitialise!() {
//            Logger.log("Failed to deinitialise \(dmaFail.name)", type: .error)
//            return
//        }
//    }
//    
//    Logger.log("Deinitialising kernel exploit (\(landa.name))")
//    if !landa.deinitialise!() {
//        Logger.log("Failed to deinitialise \(landa.name)", type: .error)
//        return
//    }
//    
//    Logger.log("Unsandboxing")
//    if !unsandbox() {
//        Logger.log("Failed to unsandbox", type: .error)
//        return
//    }
//    
//    Logger.log("Escalating privileges")
//    if !get_root_pplrw() {
//        Logger.log("Failed to escalate privileges", type: .error)
//        return
//    }
//    if !platformise() {
//        Logger.log("Failed to platformise", type: .error)
//        return
//    }
//    
//    remount_private_preboot()
//    if !fileManager.fileExists(atPath: "/private/preboot/tmp/trollstorehelper") && !fileManager.fileExists(atPath: "/private/preboot/tmp/TrollStore.tar") {
//        Logger.log("Extracting TrollStore.tar")
//        if !extract_trollstore() {
//            Logger.log("Failed to extract TrollStore.tar", type: .error)
//            return
//        }
//    }
//    
//    Logger.log("Installing TrollStore")
//    if !install_trollstore(Bundle.main.bundlePath + "/TrollStore.tar") {
//        Logger.log("Failed to install TrollStore", type: .error)
//        return
//    }
//    
//    if !cleanup_private_preboot() {
//        Logger.log("Failed to clean up /private/preboot", type: .error)
//        return
//    }
//    
//    Logger.log("Successfully installed TrollStore", type: .success)
    
    return
}
