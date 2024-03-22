//
//  Install.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import Foundation

enum InstallType {
    case direct
    case indirect
}

struct Install {
    let type: InstallType
    let exploits: [Exploit]
}
