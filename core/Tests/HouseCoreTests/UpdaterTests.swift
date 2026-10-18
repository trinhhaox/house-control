import XCTest
@testable import HouseCore

final class UpdaterTests: XCTestCase {
    func testVersionComparison() {
        // Standard semantic versions
        XCTAssertTrue(AppUpdater.isVersion("1.0.2", newerThan: "1.0.1"))
        XCTAssertTrue(AppUpdater.isVersion("1.1.0", newerThan: "1.0.9"))
        XCTAssertTrue(AppUpdater.isVersion("2.0.0", newerThan: "1.99.99"))
        XCTAssertTrue(AppUpdater.isVersion("1.0.10", newerThan: "1.0.2"))

        // With 'v' prefix
        XCTAssertTrue(AppUpdater.isVersion("v1.0.2", newerThan: "1.0.1"))
        XCTAssertTrue(AppUpdater.isVersion("v1.0.2", newerThan: "v1.0.1"))
        XCTAssertFalse(AppUpdater.isVersion("v1.0.1", newerThan: "1.0.1"))

        // Older or equal versions
        XCTAssertFalse(AppUpdater.isVersion("1.0.1", newerThan: "1.0.2"))
        XCTAssertFalse(AppUpdater.isVersion("1.0.1", newerThan: "1.0.1"))
        XCTAssertFalse(AppUpdater.isVersion("0.9.9", newerThan: "1.0.0"))
    }

    func testReleaseDecoding() throws {
        let sampleJSON = """
        {
            "tag_name": "v1.0.2",
            "name": "House Control 1.0.2",
            "body": "## What's new\\n- Added room sensors\\n- Added climate sheets",
            "html_url": "https://github.com/0xProbabillity/house-control/releases/tag/v1.0.2",
            "published_at": "2026-10-18T12:00:00Z",
            "draft": false,
            "prerelease": false,
            "assets": [
                {
                    "name": "HouseControl-1.0.2.dmg",
                    "browser_download_url": "https://github.com/0xProbabillity/house-control/releases/download/v1.0.2/HouseControl-1.0.2.dmg",
                    "size": 15420100
                },
                {
                    "name": "HouseControl-1.0.2.dmg.sha256",
                    "browser_download_url": "https://github.com/0xProbabillity/house-control/releases/download/v1.0.2/HouseControl-1.0.2.dmg.sha256",
                    "size": 64
                }
            ]
        }
        """

        let release = try JSONDecoder().decode(TestGitHubReleasePayload.self, from: Data(sampleJSON.utf8))
        XCTAssertEqual(release.tagName, "v1.0.2")
        XCTAssertEqual(AppUpdater.cleanVersion(release.tagName), "1.0.2")

        let dmg = release.assets?.first(where: { $0.name.hasSuffix(".dmg") })
        XCTAssertNotNil(dmg)
        XCTAssertEqual(dmg?.name, "HouseControl-1.0.2.dmg")
        XCTAssertEqual(dmg?.size, 15420100)
    }
}

private struct TestGitHubReleasePayload: Decodable {
    let tagName: String
    let name: String?
    let body: String?
    let htmlUrl: String
    let publishedAt: String?
    let draft: Bool?
    let prerelease: Bool?
    let assets: [TestGitHubAssetPayload]?

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case publishedAt = "published_at"
        case draft
        case prerelease
        case assets
    }
}

private struct TestGitHubAssetPayload: Decodable {
    let name: String
    let browserDownloadUrl: String
    let size: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadUrl = "browser_download_url"
        case size
    }
}
