import Foundation
import PMKFoundation

/// A type represeting a player profile for Competitive Crucible in Destiny 2.
public struct Profile {

    /// The player that owns this profile.
    public let player: Player

    /// The current Glory progression statistics for the player.
    public let glory: Progression

    /// The player's current win streak across characters.
    public var currentWinStreak: UInt {
        var potentialStreakPeriod: [Date] = []
        var mostRecentStreakLoss = Date.distantPast

        // Collect each character's streak activity dates as well as the most recent
        // streak-breaking loss across all characters
        for history in activityHistories {
            potentialStreakPeriod.append(contentsOf: history.streakActivities.map { $0.date })
            if history.mostRecentLossPeriod > mostRecentStreakLoss {
                mostRecentStreakLoss = history.mostRecentLossPeriod
            }
        }

        // Filter the streak activity periods to only those more recent than the most recent loss
        let actualStreakPeriod = potentialStreakPeriod.filter { $0 > mostRecentStreakLoss }

        return UInt(actualStreakPeriod.count)
    }

    /// Returns the number of matches played during the current weekly reset period across all characters.
    public var matchesPlayedThisWeek: Int {
        return activityHistories.map({ $0.matchesPlayedSinceWeeklyReset }).reduce(0, +)
    }

    /// Returns the number of matches won during the current weekly reset period across all characters.
    public var matchesWonThisWeek: Int {
        return activityHistories.map({ $0.winsSinceWeeklyReset }).reduce(0, +)
    }

    /// Indicates whether the player's current rank allows for earning weekly bonus Glory.
    public var canEarnBonusGlory: Bool {
        return rank.receivesBonusGlory
    }

    /// Indicates whether the player's current rank undergoes Glory decay when the weekly threshold isn't met.
    public var canIncurGloryDecay: Bool {
        return rank.hasGloryDecay
    }

    /// Returns the remaining number of matches the player must complete to meet the threshold requirement
    /// for the current weekly reset period.
    public var matchesRemainingToWeeklyThreshold: Int {
        guard matchesPlayedThisWeek < GloryRank.WeeklyMatchCompletionThreshold else { return 0 }
        return GloryRank.WeeklyMatchCompletionThreshold - matchesPlayedThisWeek
    }

    /// Indicates whether the player has completed the minimum number of matches during the current
    /// weekly reset period to meet the threshold requirements for their rank (either bonus Glory or avoiding decay).
    public var hasMetThresholdRequirementThisWeek: Bool {
        return matchesPlayedThisWeek >= GloryRank.WeeklyMatchCompletionThreshold
    }

    /// The Competitive Crucible activity histories for each of the player's characters.
    let activityHistories: [ActivityHistory]
}

// Conveniences for `Profile` in the context of Glory.
public extension Profile {

    /// The player's current rank based on progression.
    var rank: GloryRank {
        return GloryRank(for: glory.level)
    }

    /// The current Glory rank and subrank of the player formatted for display as text.
    var rankText: String {
        return rank.prettyPrinted
    }

    /// The remaining glory required for the player to reach the next closest rank.
    var gloryToNextRank: Int {
        return glory.nextLevelAt - glory.progressToNextLevel
    }

    /// Returns the number of successive wins that will progress the player to the next rank from their current position.
    var winsToNextRank: UInt {
        guard rank < .max else { return 0 }

        let rank = GloryRank(points: glory.currentProgress)
        var wins = currentWinStreak
        var points = glory.progressToNextLevel

        while points < glory.nextLevelAt {
            wins += 1
            points += rank.winPoints(atStreakPosition: wins)
        }

        return wins - currentWinStreak
    }

    /// Returns the number of successive wins that will progress the player to Fabled rank from their current position.
    var winsToFabled: UInt {
        return winsToFabled(waitingForWeeklyBonus: false)
    }

    /// Returns the number of successive wins that will progress the player to Fabled rank from their current position
    /// accounting for the weekly Glory bonus when `waiting` is set.
    func winsToFabled(waitingForWeeklyBonus waiting: Bool) -> UInt {
        guard glory.currentProgress < GloryRank.fabled(.I).startingGlory else { return 0 }

        var rank = GloryRank(points: glory.currentProgress)
        let fabledPoints = GloryRank.fabled(.I).startingGlory - (waiting ? rank.bonusGloryAmount : 0)
        var wins = currentWinStreak
        var points = glory.currentProgress

        while points < fabledPoints {
            wins += 1
            points += rank.winPoints(atStreakPosition: wins)
            rank = GloryRank(points: points)
        }

        return wins - currentWinStreak
    }

    /// Returns the current Glory progress, adding the weekly match completion bonus amount when
    /// `hasMetBonusRequirementThisWeek` is `true`.
    var gloryAtNextWeeklyReset: Int {
        //FIXME: Higher ranks incur decay until threshold is met which is not accounted for here
        //Though I won't show this value in the app for the higher ranks, this should still
        //be updated to be accurate. I'm unable to find the correct numbers, however.
        guard hasMetThresholdRequirementThisWeek else { return glory.currentProgress }
        return glory.currentProgress + rank.bonusGloryAmount
    }

    /// If the player has not yet played the minimum matches required for a Glory bonus in the current week,
    /// this property calculates the Glory that the player would have after meeting that threshold, assuming losses.
    ///
    /// If `hasMetBonusRequirementThisWeek` is `true`, this property returns `gloryAtNextWeeklyReset`.
    internal var pessimisticGloryAtNextWeeklyReset: Int {
        return minimumGloryAtNextWeeklyReset(winningNextMatch: false)
    }

    /// If the player has not yet played the minimum matches required for a Glory bonus in the current week,
    /// this property calculates the Glory that the player would have after meeting that threshold, assuming the
    /// next match is a win and any remaining are losses.
    ///
    /// If `hasMetBonusRequirementThisWeek` is `true`, this property returns `gloryAtNextWeeklyReset`.
    var optimisticGloryAtNextWeeklyReset: Int {
        return minimumGloryAtNextWeeklyReset(winningNextMatch: true)
    }

    /// Calculates the Glory the player would have following the next weekly reset if they meet the weekly bonus
    /// threshold for the current week, taking into account any progress already made towards the threshold and
    /// projecting based on whether the next game is a win or loss. Any remaining games needed to meet the
    /// threshold after the first is assumed to be a loss.
    ///
    /// If `hasMetThresholdRequirementThisWeek` is `true`, this property returns `gloryAtNextWeeklyReset`.
    internal func minimumGloryAtNextWeeklyReset(winningNextMatch withWin: Bool) -> Int {
        guard !hasMetThresholdRequirementThisWeek else { return gloryAtNextWeeklyReset }

        let pointOffset = withWin ? rank.winPoints(atStreakPosition: currentWinStreak + 1) : 0
        let matchOffset = withWin ? 1 : 0

        var points = glory.currentProgress + pointOffset
        var matches = matchesPlayedThisWeek + matchOffset
        var rank = GloryRank(points: points)

        while matches < GloryRank.WeeklyMatchCompletionThreshold {
            matches += 1
            points -= rank.lossDeficit
            rank = GloryRank(points: points)
        }

        return points + rank.bonusGloryAmount
    }

    /// Returns `true` when the player will rank up at the next weekly reset based on the current Glory
    /// point projection for their profile from `optimisticGloryAtNextWeeklyReset`.
    var willRankUpAtReset: Bool {
        guard canEarnBonusGlory else { return false }
        return GloryRank(points: optimisticGloryAtNextWeeklyReset) > rank
    }
}


//MARK: API Request

extension Bungie {
    /// Retrieves the given player's `Profile`.
    public static func getProfile(for player: Player) -> Promise<Profile> {
        let request = API.getPlayer(withId: player.membershipId, onPlatform: player.platform).request

        var thisPlayer: Player!
        var glory: Progression!

        return firstly {
            Bungie.send(request)
        }.then { data, _ -> Guarantee<[Result<ActivityHistory>]> in
            // Decode the profile's player information first because we need the character id to decode the progression
            let rawProfile = try Bungie.decoder.decode(ProfileRoot<RawProfile>.self, from: data).Response
            thisPlayer = rawProfile.profile.data.userInfo

            // Ensure the presence of associated character ids from the player
            guard let characterIds = rawProfile.profile.data.characterIds, !characterIds.isEmpty
                else { throw Model.Error.noCharactersAssociatedWithPlayer }

            // Include the last-used-character's id with the decoder for CharacterProgressions.init
            let decoder = Bungie.decoder
            decoder.userInfo[.jsonDecoderCharacterKeyName] = characterIds.first
            defer { decoder.userInfo[.jsonDecoderCharacterKeyName] = nil }

            // Decode the glory
            let rawProgressions = try decoder.decode(ProfileRoot<RawProgressions>.self, from: data).Response
            glory = rawProgressions.characterProgressions.data.firstCharacter.progressions.gloryProgress

            // Request the competitive pvp activity histories for each of the player's characters
            let activityPromises = characterIds.map({ Bungie.getActivity(forCharacterWithId: $0, associatedWith: thisPlayer) })
            return when(resolved: activityPromises)
        }.map { results in
            // Pull the histories from the fulfilled results into their own collection
            var histories: [ActivityHistory] = []
            for case .fulfilled(let history) in results { histories.append(history) }

            #if DEBUG
            print("\nProfile fetching complete\n")
            #endif

            return Profile(player: thisPlayer, glory: glory, activityHistories: histories)
        }
    }
}


//MARK: API Response

/// Generic root response dictionary because we decode the `RawProfile` and `RawProgressions` separately.
struct ProfileRoot<T>: Decodable where T: Decodable {
    let Response: T
}

/// The raw representation of the player's profile information
struct RawProfile: Decodable {
    let profile: PlayerData

    struct PlayerData: Decodable {
        let data: DetailedPlayer

        struct DetailedPlayer: Decodable {
            let userInfo: Player
            let characterIds: [String]?
        }
    }
}

/// The raw representation of the player's progression information
struct RawProgressions: Decodable {
    let characterProgressions: CharacterProgressionsData

    struct CharacterProgressionsData: Decodable {
        let data: CharacterProgressions

        struct CharacterProgressions: Decodable {
            let firstCharacter: Character

            init(from decoder: Decoder) throws {
                guard let characterId = decoder.userInfo[.jsonDecoderCharacterKeyName] as? String
                    else { throw Model.Error.noCharactersAssociatedWithPlayer }

                //We must custom decode because we need the id of a character from the `RawProfile` first
                let container = try decoder.container(keyedBy: DynamicKey.self)
                firstCharacter = try container.decode(Character.self, forKey: .named(characterId))
            }

            struct Character: Decodable {
                let progressions: Progressions

                struct Progressions: Decodable {
                    let gloryProgress: Progression

                    init(from decoder: Decoder) throws {
                        //We must custom decode because the coding key is an integer which cannot be represented in Swift
                        let container = try decoder.container(keyedBy: CodingKey.self)
                        gloryProgress = try container.decode(Progression.self, forKey: .gloryKey)
                    }

                    enum CodingKey: String, Swift.CodingKey {
                        case gloryKey = "2000925172"
                    }
                }
            }
        }
    }
}

//MARK: Helpers

private struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init(intValue: Int) {
        self.intValue = intValue
        stringValue = "\(intValue)"
    }

    static func named(_ name: String) -> DynamicKey {
        return DynamicKey(stringValue: name)
    }
}

extension CodingUserInfoKey {
    static let jsonDecoderCharacterKeyName = CodingUserInfoKey(rawValue: "fabledCharacterKeyName")!
}
