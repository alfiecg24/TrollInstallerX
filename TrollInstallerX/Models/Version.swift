//
//  Version.swift
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

import Foundation

struct Version: Comparable, Equatable {
    let major: Int
    let minor: Int
    let patch: Int?
    
    init(major: Int, minor: Int, patch: Int? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init(_ version: String) {
        let components = version.components(separatedBy: ".")
        let major = Int(components[0])
        let minor = Int(components[1])
        self.major = major!
        self.minor = minor!
        if components.count == 3, let patch = Int(components[2]) {
            self.patch = patch
        } else {
            self.patch = nil
        }
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major < rhs.major { return true }
        if lhs.major > rhs.major { return false }
        if lhs.minor < rhs.minor { return true }
        if lhs.minor > rhs.minor { return false }
        if (lhs.patch != nil) {
            if (rhs.patch == nil) { return false }
            return lhs.patch! < rhs.patch!
        }
        return (rhs.patch != nil)
    }
    
    var readableString: String {
        var str = "\(major).\(minor)"
        if (self.patch != nil) { str += ".\(patch!)" }
        return str
    }
    
}
