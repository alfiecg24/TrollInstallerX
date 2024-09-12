//
//  Update.swift
//  TrollInstallerX
//
//  Created by Alfie on 30/03/2024.
//

import Foundation

// Function to download a file into memory instead of writing to a file on disk
// https://api.github.com/repos/opa334/TrollStore/releases/latest
// https://github.com/opa334/TrollStore/releases/latest/download/TrollStore.tar
func downloadFile(from url: URL) async throws -> URL {
    return try await withCheckedThrowingContinuation { continuation in
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            if let tempURL = tempURL {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent + ".latest")
                
                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    continuation.resume(returning: destinationURL)
                } catch {
                    continuation.resume(throwing: error)
                }
            } else if let error = error {
                continuation.resume(throwing: error)
            } else {
                // Handle unexpected case where both tempURL and error are nil
                let unexpectedError = NSError(domain: "com.Alfie.TrollInstallerX", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected error"])
                continuation.resume(throwing: unexpectedError)
            }
        }
        task.resume()
    }
}

let bundledVersion = Version("2.1")
func getUpdatedTrollStore() async {
    var outOfDate = false
    var doneChecking = false
    var newVersion = ""
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    github_fetchLatestVersion("opa334/TrollStore", { version in
        if let version = version {
            print("Current version: \(version)")
            let currentVersion = Version(version)
            if currentVersion > bundledVersion && currentVersion > Version(TIXDefaults().string(forKey: "localVersion") ?? "0.0.0") {
                print("Out of date!")
                newVersion = version
                try? FileManager.default.removeItem(at: documentsURL.appendingPathComponent("TrollStore.tar"))
                outOfDate = true
            }
        }
        doneChecking = true
    })
    while !doneChecking { }
    if outOfDate {
        do {
            let newFile = try await downloadFile(from: URL(string: "https://github.com/opa334/TrollStore/releases/latest/download/TrollStore.tar")!)
            print("Done downloading")
            let newURL = newFile
            print("New: \(newURL.path)")
            try FileManager.default.moveItem(at: newFile, to: documentsURL.appendingPathComponent("TrollStore.tar"))
            TIXDefaults().setValue(newVersion, forKey: "localVersion")
        } catch {
            print("Failed to download/move TrollStore.tar - \(error.localizedDescription)")
        }
    }
}
