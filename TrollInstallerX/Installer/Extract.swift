//
//  Extract.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import Foundation

func extractTrollStore(_ useLocalCopy: Bool) -> Bool {
    let fileManager = FileManager.default
    let tarPath = useLocalCopy ? "/private/preboot/tmp/TrollStore.tar" : Bundle.main.url(forResource: "TrollStore", withExtension: "tar")?.path
    let extractPath = "/private/preboot/tmp/TrollStore"
    
    // Extract the .tar
    if libarchive_unarchive(tarPath, extractPath) != 0 {
        return false
    }
    
    let trollHelperPath = "/private/preboot/tmp/trollstorehelper"
    
    // If it already the user is probably retrying after a failed attempt
    if !fileManager.fileExists(atPath: trollHelperPath) {
        do {
            try fileManager.copyItem(atPath: extractPath + "/TrollStore.app/trollstorehelper", toPath: trollHelperPath)
        } catch let e {
            print("Failed to copy trollstorehelper! \(e.localizedDescription)")
            return false
        }
    }
    
    do {
        // Get the current file permissions
        let attributes = try fileManager.attributesOfItem(atPath: trollHelperPath)
        var permissions = attributes[.posixPermissions] as? UInt16 ?? 0
        
        // Set the executable bit
        permissions |= 0o111 // Add execute permission for owner, group, and others
        
        // Update the file permissions
        try fileManager.setAttributes([.posixPermissions: permissions], ofItemAtPath: trollHelperPath)
    } catch let e {
        print("Failed to set helper as executable! \(e.localizedDescription)")
        return false
    }
    
    return true
}

func extractTrollStoreIndirect() -> Bool {
    // Check docs for TrollStore.tar
    // If that doesn't exist, we copy bundled
    
    let fm = FileManager.default
    let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let local = docs.appendingPathComponent("TrollStore.tar")
    let bundled = Bundle.main.url(forResource: "TrollStore", withExtension: "tar")
    
    let extractPath = docs.appendingPathComponent("TrollStore")
    
    cleanupIndirectInstall()
    
    if fm.fileExists(atPath: local.path) {
        if fm.fileExists(atPath: extractPath.path) {
            try? fm.removeItem(at: extractPath)
        }
        if libarchive_unarchive(local.path, extractPath.path) != 0 {
            Logger.log("Failed to extract TrollStore", type: .error)
            return false
        }
    } else {
        let copyPath = docs.appendingPathComponent("Bundled.tar")
        if !fm.fileExists(atPath: copyPath.path) {
            if let bundledTar = bundled {
                do {
                    try fm.copyItem(at: bundledTar, to: copyPath)
                } catch {
                    Logger.log("Failed to copy TrollStore.tar", type: .error)
                    print("Failed to copy TrollStore.tar - \(error.localizedDescription)")
                    return false
                }
            } else {
                return false
            }
        }
        if libarchive_unarchive(copyPath.path, extractPath.path) != 0 {
            Logger.log("Failed to extract TrollStore", type: .error)
            return false
        }
        
    }
    
    // We can assume the TrollStore directory exists, so now copy files
    let rootHelperPath = extractPath.appendingPathComponent("TrollStore.app").appendingPathComponent("trollstorehelper")
    let persistenceHelperPath = extractPath.appendingPathComponent("TrollStore.app").appendingPathComponent("PersistenceHelper")
    
    let rootHelperCopy = docs.appendingPathComponent("trollstorehelper")
    let persistenceHelperCopy = docs.appendingPathComponent("PersistenceHelper")
    
    do {
        try fm.copyItem(at: rootHelperPath, to: rootHelperCopy)
        try fm.copyItem(at: persistenceHelperPath, to: persistenceHelperCopy)
    } catch {
        Logger.log("Failed to copy executables", type: .error)
        print("Failed to copy \(fm.fileExists(atPath: rootHelperCopy.path) ? "persistence helper" : "root helper") - \(error.localizedDescription)")
        return false
    }
    
    // Final check
    return fm.fileExists(atPath: rootHelperCopy.path) && fm.fileExists(atPath: persistenceHelperCopy.path)
}

func cleanupIndirectInstall() {
    let fm = FileManager.default
    let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let extract = docs.appendingPathComponent("TrollStore")
    let rootHelper = docs.appendingPathComponent("trollstorehelper")
    let persistenceHelper = docs.appendingPathComponent("PersistenceHelper")
    let dotFile = docs.appendingPathComponent(".TrollStorePersistenceHelper")
    try? fm.removeItem(at: extract)
    try? fm.removeItem(at: rootHelper)
    try? fm.removeItem(at: persistenceHelper)
    try? fm.removeItem(at: dotFile)
}
