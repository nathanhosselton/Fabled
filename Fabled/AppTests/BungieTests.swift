import XCTest
@testable import Fabled
@testable import Model
import PromiseKit

class BungieTests: XCTestCase {

    override func setUp() {
        Bungie.key = FabledAppKey
        Bungie.appId = FabledAppId
        Bungie.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    func testBungieRequestSuite() {
        let x = expectation(description: "Test full chain of requests against the Bungie.net API")

        firstly {
            Bungie.searchForPlayer(with: "WeirdRituals", on: .steam)
        }.then {
            Bungie.getProfile(for: $0[0])
        }.done {
            x.fulfill()
            print($0)
        }.catch {
            XCTFail($0.localizedDescription)
            x.fulfill()
        }

        wait(for: [x], timeout: 10.0)
    }

}
