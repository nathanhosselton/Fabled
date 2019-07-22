import XCTest
@testable import Model

class ProgressionTests: XCTestCase {

    func testDecodeProgressionFromGetPlayerResponse() {
        let exampleResponseData =
            """
            {
                "Response": {
                    "characterProgressions": {
                        "data": {
                            "2305843009301040747": {
                                "progressions": {
                                    "2000925172": {
                                        "progressionHash": 2000925172,
                                        "dailyProgress": 0,
                                        "dailyLimit": 0,
                                        "weeklyProgress": 0,
                                        "weeklyLimit": 0,
                                        "currentProgress": 2184,
                                        "level": 9,
                                        "levelCap": 0,
                                        "stepIndex": 9,
                                        "progressToNextLevel": 84,
                                        "nextLevelAt": 280
                                    }
                                }
                            }
                        }
                    }
                }
            }
            """
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .data(using: .utf8)!

        do {
            let decoder = Bungie.decoder
            decoder.userInfo[.jsonDecoderCharacterKeyName] = "2305843009301040747"
            _ = try decoder.decode(ProfileRoot<RawProgressions>.self, from: exampleResponseData)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
