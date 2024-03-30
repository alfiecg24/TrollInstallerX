//
//  Extract.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import Foundation

func extract_trollstore(_ useLocalCopy: Bool) -> Bool {
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
