//
//  download.swift
//  TrollInstallerX
//
//  Created by Alfie on 09/03/2024.
//

import Foundation

// "https://github.com/opa334/TrollStore/releases/latest/download/TrollStore.tar"

func downloadTrollStore(_ docsDir: String) -> Bool {
    let url = URL(string: "https://github.com/opa334/TrollStore/releases/latest/download/TrollStore.tar")
    var ret = false
    let task = URLSession.shared.downloadTask(with: url!) { localURL, urlResponse, error in
        if let localURL = localURL {
            if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let destURL = docsURL.appendingPathComponent("TrollStore.tar")
                do {
                    try FileManager.default.moveItem(at: localURL, to: destURL)
                    ret = true
                } catch (let writeError) {
                    print("Error writing file \(destURL) : \(writeError)")
                }
            }
        }
    }
    task.resume()
    return ret
}

func downloadFile(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
    let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
        guard let tempURL = tempURL else {
            completion(nil, error)
            return
        }
        
        // Create a destination URL to move the downloaded file
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        
        // Move the downloaded file from the temporary location to the destination URL
        do {
            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            completion(destinationURL, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    task.resume()
}

func extractTrollStore(_ docsDir: String) -> Bool {
    let fileManager = FileManager.default
    let tarPath = Bundle.main.url(forResource: "TrollStore", withExtension: "tar")?.path
    let extractPath = docsDir + "/TrollStore"
    if libarchive_unarchive(tarPath, extractPath) != 0 {
        return false
    }
    
    let trollHelperPath = docsDir + "/trollstorehelper"
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
        var attributes = try fileManager.attributesOfItem(atPath: trollHelperPath)
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
