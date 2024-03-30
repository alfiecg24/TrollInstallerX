//
//  GitHubResponse.swift
//  TrollInstallerX
//
//  Created by Alfie on 30/03/2024.
//

import Foundation

// MARK: - GitHubResponse
struct GitHubResponse: Codable {
    let url, assetsURL: String
    let uploadURL: String
    let htmlURL: String
    let id: Int
    let author: Author
    let nodeID, tagName, targetCommitish, name: String
    let draft, prerelease: Bool
    let createdAt, publishedAt: Date
    let assets: [Asset]
    let tarballURL, zipballURL: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case url
        case assetsURL = "assets_url"
        case uploadURL = "upload_url"
        case htmlURL = "html_url"
        case id, author
        case nodeID = "node_id"
        case tagName = "tag_name"
        case targetCommitish = "target_commitish"
        case name, draft, prerelease
        case createdAt = "created_at"
        case publishedAt = "published_at"
        case assets
        case tarballURL = "tarball_url"
        case zipballURL = "zipball_url"
        case body
    }
}

// MARK: - Asset
struct Asset: Codable {
    let url: String
    let id: Int
    let nodeID, name: String
    let label: JSONNull?
    let uploader: Author
    let contentType, state: String
    let size, downloadCount: Int
    let createdAt, updatedAt: Date
    let browserDownloadURL: String

    enum CodingKeys: String, CodingKey {
        case url, id
        case nodeID = "node_id"
        case name, label, uploader
        case contentType = "content_type"
        case state, size
        case downloadCount = "download_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case browserDownloadURL = "browser_download_url"
    }
}

// MARK: - Author
struct Author: Codable {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url, htmlURL, followersURL: String
    let followingURL, gistsURL, starredURL: String
    let subscriptionsURL, organizationsURL, reposURL: String
    let eventsURL: String
    let receivedEventsURL: String
    let type: String
    let siteAdmin: Bool

    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type
        case siteAdmin = "site_admin"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
