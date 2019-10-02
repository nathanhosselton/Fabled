import XCTest
@testable import Model

class PlayerTests: XCTestCase {

    func testDecodePlayerFromGetSearchPlayerResponse() {
        let exampleResponseData =
        """
        {
            "Response": [
                {
                    "membershipType": 3,
                    "membershipId": "4611686018468167462",
                    "displayName": "WeirdRituals"
                }
            ]
        }
        """
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .data(using: .utf8)!

        do {
            _ = try Bungie.decoder.decode(PlayerSearchMetaResponse.self, from: exampleResponseData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDecodePlayerFromGetPlayerResponse() {
        let exampleResponseData =
        """
        {
            "Response": {
                "profile": {
                    "data": {
                        "userInfo": {
                            "membershipType": 3,
                            "membershipId": "4611686018468167462",
                            "displayName": "WeirdRituals"
                        },
                        "characterIds": [
                            "2305843009301040747",
                            "2305843009350194973",
                            "2305843009355954197"
                        ]
                    }
                }
            }
        }
        """
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .data(using: .utf8)!

        do {
            _ = try Bungie.decoder.decode(ProfileRoot<RawProfile>.self, from: exampleResponseData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
