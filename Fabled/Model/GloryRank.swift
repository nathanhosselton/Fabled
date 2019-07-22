import Foundation

/// A type representing the progression ranks in Competitive Crucible.
public enum GloryRank {

    /// The subranks available within certain `GloryRank`s.
    public enum Subrank: String, CaseIterable {
        case I, II, III
    }

    case guardian(Subrank)
    case brave(Subrank)
    case heroic(Subrank)
    case fabled(Subrank)
    case mythic(Subrank)
    case legend
    case max

    /// The number completed games required each week to award bonus Glory at the next weekly reset
    public static let MatchCompletionBonusThreshold = 3

    /// The amount of Glory awarded at the next weekly reset after meeting the `MatchCompletionBonusThreshold`.
    public static let MatchCompletionBonusAmount = 120

    /// Returns the rank `title` with the subrank formatted for display.
    var prettyPrinted: String {
        switch self {
        case .guardian(let sub), .brave(let sub), .heroic(let sub), .fabled(let sub), .mythic(let sub):
            return title + " \(sub)"
        case .legend, .max:
            return title
        }
    }

    /// The title of the rank, e.g. "Fabled".
    var title: String {
        switch self {
        case .guardian:
            return "Guardian"
        case .brave:
            return "Brave"
        case .heroic:
            return "Heroic"
        case .fabled:
            return "Fabled"
        case .mythic:
            return "Mythic"
        case .legend:
            return "Legend"
        case .max:
            return "Max"
        }
    }

    /// Returns the level value for the rank corresponding to the the API.
    var level: Int {
        //Easier to return index of self within `allCases` but its sorting depends on this var.
        switch self {
        case .guardian(.I):
            return 0
        case .guardian(.II):
            return 1
        case .guardian(.III):
            return 2
        case .brave(.I):
            return 3
        case .brave(.II):
            return 4
        case .brave(.III):
            return 5
        case .heroic(.I):
            return 6
        case .heroic(.II):
            return 7
        case .heroic(.III):
            return 8
        case .fabled(.I):
            return 9
        case .fabled(.II):
            return 10
        case .fabled(.III):
            return 11
        case .mythic(.I):
            return 12
        case .mythic(.II):
            return 13
        case .mythic(.III):
            return 14
        case .legend:
            return 15
        case .max:
            return 16
        }
    }

    /// Returns the Glory point range for the rank.
    var pointRange: ClosedRange<Int> {
        switch self {
        case .guardian(.I):
            return 0...39
        case .guardian(.II):
            return 40...109
        case .guardian(.III):
            return 110...199
        case .brave(.I):
            return 200...369
        case .brave(.II):
            return 370...664
        case .brave(.III):
            return 665...1049
        case .heroic(.I):
            return 1050...1259
        case .heroic(.II):
            return 1260...1624
        case .heroic(.III):
            return 1625...2099
        case .fabled(.I):
            return 2100...2379
        case .fabled(.II):
            return 2380...2869
        case .fabled(.III):
            return 2870...3499
        case .mythic(.I):
            return 3500...3879
        case .mythic(.II):
            return 3880...4544
        case .mythic(.III):
            return 4545...5449
        case .legend:
            return 5450...5499
        case .max:
            return 5500...5500
        }
    }

    /// Returns `pointRange.count` i.e. the point amount that the rank encompasses.
    var pointLength: Int {
        return pointRange.count
    }

    /// Returns `pointRange.lowerBound` i.e. the point amount at which the rank begins.
    var startingGlory: Int {
        return pointRange.lowerBound
    }

    /// Returns `pointRange.upperBound` i.e. the point amount at which the rank ends.
    var endingGlory: Int {
        return pointRange.upperBound
    }

    /// Returns the amount of Glory that is deducted for a match loss. This value is positive.
    var lossDeficit: Int {
        switch self {
        case .heroic:
            return 52
        case .guardian, .brave, .fabled:
            return 60
        case .mythic, .legend, .max:
            return 68
        }
    }

    /// Returns the amount of glory received for the first win following a loss.
    var baseWinPoints: Int {
        switch self {
        case .guardian:
            return 80
        case .brave:
            return 68
        case .heroic:
            return 60
        case .fabled, .mythic, .legend:
            return 40
        default:
            return 0
        }
    }

    /// Returns the amount of bonus glory received at a given streak position relative to the preceeding position.
    func winBonus(atStreakPosition streakPosition: UInt) -> Int {
        guard 2...5 ~= streakPosition else { return 0 }

        switch self {
        case .guardian:
            return 20
        case .brave, .heroic, .fabled, .mythic, .legend:
            switch streakPosition {
            case 2...3:
                return 20
            case 4:
                return 28
            case 5:
                return 12
            default:
                return 0 //Impossible due to guard
            }
        case .max:
            return 0
        }
    }

    /// Returns the glory rewarded for a win at the given streak position.
    func winPoints(atStreakPosition streakPosition: UInt) -> Int {
        guard streakPosition > 0 else { return 0 }

        var bonus = 0
        for position in 0...streakPosition {
            bonus += winBonus(atStreakPosition: position)
        }

        return baseWinPoints + bonus
    }

    /// Returns the rank of the provided `Progression` level value.
    init(for level: Int) {
        guard 0...GloryRank.max.level ~= level
            else { self = .max; return }

        self = GloryRank.allCases.first(where: { $0.level == level })!
    }

    /// Returns a rank based on the provided Glory point value.
    init(points: Int) {
        guard 0...GloryRank.max.endingGlory ~= points
            else { self = .max; return }

        self = GloryRank.allCases.first(where: { $0.pointRange ~= points })!
    }
}

extension GloryRank: CaseIterable {
    public static var allCases: [GloryRank] {
        var allCases: [GloryRank] = [.legend, .max]

        for subrank in Subrank.allCases {
            allCases.append(contentsOf: [
                .guardian(subrank),
                .brave(subrank),
                .heroic(subrank),
                .fabled(subrank),
                .mythic(subrank)
                ])
        }

        return allCases.sorted()
    }

    /// Alias for `allCases`.
    public static var allRanks: [GloryRank] {
        return allCases
    }
}

extension GloryRank: Comparable {
    public static func < (lhs: GloryRank, rhs: GloryRank) -> Bool {
        return lhs.level < rhs.level
    }
}

extension GloryRank: CustomStringConvertible {
    public var description: String {
        return prettyPrinted
    }
}
