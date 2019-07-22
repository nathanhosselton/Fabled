import Foundation

/// A type representing generic progressables from the Bungie.net API. For us, this will specifically represent Glory.
public struct Progression: Decodable {

    /// The net glory accrued by the player within the current daily reset period.
    public let dailyProgress: Int

    /// The net glory accrued by the player within the current weekly reset period.
    public let weeklyProgress: Int

    /// The net glory accrued by the player this season.
    public let currentProgress: Int

    /// The current subrank value of the player in competitive where 0 is the starting rank.
    public let level: Int

    /// The amount of glory accrued by the player within their current subrank.
    public let progressToNextLevel: Int

    /// The glory threshold for the player's next closest subrank, relative to their current subrank.
    public let nextLevelAt: Int
}
