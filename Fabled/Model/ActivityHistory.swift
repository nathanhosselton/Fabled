import Foundation
import PMKFoundation

/// A type representing the activity history for a player character. In our case, this specifically tracks
/// history in the Competitive Crucible playlist.
struct ActivityHistory: Decodable {
    struct StreakActivity: Decodable {
        /// The date period when this activity occurred.
        let date: Date
    }

    /// The date period of the most recent activity, win or loss.
    let lastestActivityPeriod: Date

    /// The current win streak based on this object's activities.
    let currentStreak: Int

    /// The date period of the most recent loss. Mirrors `lastestActivityPeriod` when `currentStreak` is `0`.
    let mostRecentLossPeriod: Date

    /// The number of matches in the activity history which have occurred during the current weekly reset period.
    let matchesPlayedSinceWeeklyReset: Int

    /// The number of matches won during the current weekly reset period.
    let winsSinceWeeklyReset: Int

    /// The activities which contributed to the current streak, ordered by most recent. Empty
    /// when the `currentStreak` is `0`.
    let streakActivities: [StreakActivity]

    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKey.self)
        let activities = try root.decode(ActivityHistoryRoot.Activities.self, forKey: .Response).activities

        // Decodoable inits aren't failable, but this object is pointless without activity, so we throw.
        guard let latestActivity = activities.first else { throw NonFatalError.noActivityHistoryForCharacter }

        lastestActivityPeriod = latestActivity.period

        /// The interval of time since the most recent weekly reset until now.
        let intervalSinceLastReset: DateInterval = {
            let utc = TimeZone(identifier: "UTC")!
            var utcCalendar = Calendar.current; utcCalendar.timeZone = utc
            let search = DateComponents(timeZone: utc, hour: 17, weekday: 3) //Weekly reset in UTC
            let mostRecentResetPeriod = utcCalendar.nextDate(after: Date(), matching: search, matchingPolicy: .nextTime, direction: .backward)!
            return DateInterval(start: mostRecentResetPeriod, end: Date().addingTimeInterval(1))
        }()

        let matchesSinceWeeklyReset = activities.filter { intervalSinceLastReset.contains($0.completionPeriod) }
        matchesPlayedSinceWeeklyReset = matchesSinceWeeklyReset.count
        winsSinceWeeklyReset = matchesSinceWeeklyReset.filter { !$0.wasLost }.count

        // The streak is the length of wins from the most recent activity until the first loss
        currentStreak = activities.firstIndex(where: { $0.wasLost }) ?? activities.endIndex

        if currentStreak > 0 {
            // The first activity following the end of the streak
            mostRecentLossPeriod = currentStreak < activities.endIndex
                                                 ? activities[currentStreak].period
                                                 : Date.distantPast //no losses on record
            streakActivities = activities.prefix(currentStreak).map { StreakActivity(date: $0.period) }
        } else {
            mostRecentLossPeriod = lastestActivityPeriod
            streakActivities = []
        }
    }

    enum CodingKey: Swift.CodingKey {
        case Response
    }
}


//MARK: API Request

extension Bungie {
    internal static func getActivity(forCharacterWithId id: String, associatedWith player: Player) -> Promise<ActivityHistory> {
        let request = Bungie.API.getCompetitiveHistory(forCharacterWithId: id,
                                                       associatedWithPlayerId: player.membershipId,
                                                       onPlatform: player.platform).request

        return firstly {
            Bungie.send(request)
        }.map { data, _ in
            try Bungie.decoder.decode(ActivityHistory.self, from: data)
        }
    }
}


//MARK: API Response

struct ActivityHistoryRoot: Decodable {
    let Response: Activities

    struct Activities: Decodable {
        let activities: [MetaActivity]

        struct MetaActivity: Decodable {
            let period: Date
            let values: ActivityDetails

            var wasLost: Bool {
                return values.standing.basic.value == 1
            }

            var completionPeriod: Date {
                return period.addingTimeInterval(values.activityDurationSeconds.basic.value)
            }

            struct ActivityDetails: Decodable {
                let standing: Standing
                let activityDurationSeconds: ActivityDuration

                struct Standing: Decodable {
                    let basic: Result

                    struct Result: Decodable {
                        let value: Int
                        let displayValue: String
                    }
                }

                struct ActivityDuration: Decodable {
                    let basic: Result

                    struct Result: Decodable {
                        let value: TimeInterval
                        let displayValue: String
                    }
                }
            }
        }
    }
}
