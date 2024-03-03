//
//  BuildManifest.swift
//  TrollInstallerX
//
//  Created by Alfie on 14/02/2024.
//

import Foundation

func getKernelPath(buildManifestPath: String, model: String) -> String? {
    guard let dict = NSDictionary(contentsOfFile: buildManifestPath),
          let identities = dict["BuildIdentities"] as? [[String: Any]] else {
        print("Unable to read build manifest or identities!")
        return nil
    }
    
    for item in identities {
        guard let info = item["Info"] as? [String: Any],
              let hwmodel = info["DeviceClass"] as? String,
              hwmodel.caseInsensitiveCompare(model) == .orderedSame,
              let manifest = item["Manifest"] as? [String: Any],
              let kcache = manifest["KernelCache"] as? [String: Any],
              let kinfo = kcache["Info"] as? [String: Any],
              let kpath = kinfo["Path"] as? String else {
            continue
        }
        if !kpath.contains("research") {
            return kpath
        }
    }
    
    print("Kernel path not found!")
    return nil
}

