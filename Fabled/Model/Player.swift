import Foundation
import PMKFoundation

/// A type for representing a player of Destiny 2.
public struct Player: Codable {

    /// The player's chosen name on their platform.
    /// - Note: In the context of player searches, this property will include the trailing
    /// tag for Battlenet ids. When performing a GET on a specific player, it will not.
    public let displayName: String

    /// The platform on which this player account originates.
    public var platform: Bungie.Platform {
        return .init(rawValue: .some(membershipType))
    }

    /// The raw value that represent's the player account's platform.
    internal let membershipType: Int
    /// The unique platform-specific identifier of this player account.
    internal let membershipId: String
}

extension Player: Comparable {
    public static func < (lhs: Player, rhs: Player) -> Bool {
        return lhs.displayName < rhs.displayName
    }

    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.displayName == rhs.displayName && lhs.membershipId == rhs.membershipId
    }
}

extension Player: Hashable
{}


//MARK: API Request

extension Bungie {
    /// Performs a search for the given player tag on the provided platform.
    /// - Note: Searches for `.blizzard` players requires inclusion of the trailing hash, e.g. "#1234".
    public static func searchForPlayer(with tag: String, on platform: Platform) -> Promise<[Player]> {
        let request = API.getFindPlayer(withQuery: tag, onPlatform: platform).request

        return firstly {
            Bungie.send(request)
        }.map(on: .global()) { data, _ in
            try Bungie.decoder.decode(PlayerSearchMetaResponse.self, from: data).Response
        }
    }
}


//MARK: API Response

struct PlayerSearchMetaResponse: Decodable {
    let Response: [Player]
}
