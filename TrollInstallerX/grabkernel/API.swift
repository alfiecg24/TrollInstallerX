//
//  API.swift
//  TrollInstallerX
//
//  Created by Alfie on 10/02/2024.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let version = try? JSONDecoder().decode(Version.self, from: jsonData)

import Foundation

// Everything that we don't actually need can be optional

// MARK: - Version
struct Version: Codable {
    let osStr, version, build, buildTrain: String
    let released: String?
    let releaseNotes, securityNotes: String?
    let ipd: Ipd?
    let appledbWebImage: AppledbWebImage?
    let deviceMap: [String]?
    let sources: [Source]?
    let uniqueBuild, key: String?
    let beta, rc: Bool
    let preinstalled: [String?]?
    let osType: String?
    let devices: [String: Device]
    let appledburl: String?
}

// MARK: - AppledbWebImage
struct AppledbWebImage: Codable {
    let id, align: String?
}

// MARK: - Device
struct Device: Codable {
    let ipsw: String
}

// MARK: - Ipd
struct Ipd: Codable {
    let iPhone, iPod: String?
}

// MARK: - Source
struct Source: Codable {
    let type: String?
    let deviceMap: [String]?
    let links: [Link]?
    let hashes: Hashes?
    let size: Int?
}

// MARK: - Hashes
struct Hashes: Codable {
    let sha1, sha2256: String?
}

// MARK: - Link
struct Link: Codable {
    let url: String?
    let preferred, active: Bool?
}

func getIPSWURL() async throws -> String? {
    let version = try await fetchAndParseVersion()
    var url: String?
    for (_, device) in version.devices.enumerated() {
        if device.key == getMachineName() {
            print("Found URL for \(getMachineName()), \(getBuildNumber())")
            print("This is a \(version.beta ? (version.rc ? "release candidate" : "beta") : "release") build")
            url = device.value.ipsw
        }
    }
    return url
}

func fetchAndParseVersion() async throws -> Version {
    let url = getAPIURL()
    let jsonData = try await fetchData(from: url)
    return try decodeVersion(from: jsonData)
}

private func fetchData(from url: URL) async throws -> Data {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    } catch {
        throw URLError(.badServerResponse, userInfo: ["url": url])
    }
}

private func decodeVersion(from jsonData: Data) throws -> Version {
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(Version.self, from: jsonData)
    } catch {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON data"))
    }
}
