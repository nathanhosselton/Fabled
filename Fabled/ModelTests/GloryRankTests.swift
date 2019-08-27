import XCTest
@testable import Model

/// Mostly a duplication of the logic and static values in the source file for redundancy and therefore not
/// a validation of parity with the Bungie.net API nor the Destiny 2 game logic.
class GloryRankTests: XCTestCase {

    func testAllCasesIsCompleteAndOrdered() {
        let all = GloryRank.allRanks

        XCTAssert(all.count == 17)

        XCTAssert(all[0] == .guardian(.I))
        XCTAssert(all[1] == .guardian(.II))
        XCTAssert(all[2] == .guardian(.III))
        XCTAssert(all[3] == .brave(.I))
        XCTAssert(all[4] == .brave(.II))
        XCTAssert(all[5] == .brave(.III))
        XCTAssert(all[6] == .heroic(.I))
        XCTAssert(all[7] == .heroic(.II))
        XCTAssert(all[8] == .heroic(.III))
        XCTAssert(all[9] == .fabled(.I))
        XCTAssert(all[10] == .fabled(.II))
        XCTAssert(all[11] == .fabled(.III))
        XCTAssert(all[12] == .mythic(.I))
        XCTAssert(all[13] == .mythic(.II))
        XCTAssert(all[14] == .mythic(.III))
        XCTAssert(all[15] == .legend)
        XCTAssert(all[16] == .max)
    }

    func testPointRangeReturnsExpectedValues() {
        for rank in GloryRank.allRanks {
            switch rank {
            case .guardian(.I):
                XCTAssert(rank.pointRange == 0...39)
            case .guardian(.II):
                XCTAssert(rank.pointRange == 40...109)
            case .guardian(.III):
                XCTAssert(rank.pointRange == 110...199)
            case .brave(.I):
                XCTAssert(rank.pointRange == 200...369)
            case .brave(.II):
                XCTAssert(rank.pointRange == 370...664)
            case .brave(.III):
                XCTAssert(rank.pointRange == 665...1049)
            case .heroic(.I):
                XCTAssert(rank.pointRange == 1050...1259)
            case .heroic(.II):
                XCTAssert(rank.pointRange == 1260...1624)
            case .heroic(.III):
                XCTAssert(rank.pointRange == 1625...2099)
            case .fabled(.I):
                XCTAssert(rank.pointRange == 2100...2379)
            case .fabled(.II):
                XCTAssert(rank.pointRange == 2380...2869)
            case .fabled(.III):
                XCTAssert(rank.pointRange == 2870...3499)
            case .mythic(.I):
                XCTAssert(rank.pointRange == 3500...3879)
            case .mythic(.II):
                XCTAssert(rank.pointRange == 3880...4544)
            case .mythic(.III):
                XCTAssert(rank.pointRange == 4545...5449)
            case .legend:
                XCTAssert(rank.pointRange == 5450...5499)
            case .max:
                XCTAssert(rank.pointRange == 5500...5500)
            }
        }
    }

    func testGloryBaseReturnsExpectedValue() {
        for rank in GloryRank.allRanks {
            XCTAssert(rank.startingGlory == rank.pointRange.lowerBound)
        }
    }

    func testGloryCeilingReturnsExpectedValue() {
        for rank in GloryRank.allRanks {
            XCTAssert(rank.endingGlory == rank.pointRange.upperBound)
        }
    }

    func testInitWithPointsReturnsExpectedRank() {
        for rank in GloryRank.allRanks {
            XCTAssert(GloryRank(points: rank.startingGlory) == rank)
        }
    }

    func testLevelReturnsExpectedValues() {
        for rank in GloryRank.allRanks {
            switch rank {
            case .guardian(.I):
                XCTAssert(rank.level == 0)
            case .guardian(.II):
                XCTAssert(rank.level == 1)
            case .guardian(.III):
                XCTAssert(rank.level == 2)
            case .brave(.I):
                XCTAssert(rank.level == 3)
            case .brave(.II):
                XCTAssert(rank.level == 4)
            case .brave(.III):
                XCTAssert(rank.level == 5)
            case .heroic(.I):
                XCTAssert(rank.level == 6)
            case .heroic(.II):
                XCTAssert(rank.level == 7)
            case .heroic(.III):
                XCTAssert(rank.level == 8)
            case .fabled(.I):
                XCTAssert(rank.level == 9)
            case .fabled(.II):
                XCTAssert(rank.level == 10)
            case .fabled(.III):
                XCTAssert(rank.level == 11)
            case .mythic(.I):
                XCTAssert(rank.level == 12)
            case .mythic(.II):
                XCTAssert(rank.level == 13)
            case .mythic(.III):
                XCTAssert(rank.level == 14)
            case .legend:
                XCTAssert(rank.level == 15)
            case .max:
                XCTAssert(rank.level == 16)
            }
        }
    }

    func testInitWithLevelReturnsExpectedRank() {
        for rank in GloryRank.allRanks {
            XCTAssert(GloryRank(for: rank.level) == rank)
        }
    }

    func testBaseWinPointsReturnsExpectedValues() {
        for rank in GloryRank.allRanks {
            switch rank {
            case .guardian:
                XCTAssert(rank.baseWinPoints == 80)
            case .brave:
                XCTAssert(rank.baseWinPoints == 68)
            case .heroic:
                XCTAssert(rank.baseWinPoints == 60)
            case .fabled, .mythic, .legend:
                XCTAssert(rank.baseWinPoints == 40)
            case .max:
                XCTAssert(rank.baseWinPoints == 0)
            }
        }
    }

    func testWinBonusReturnsExpectedValues() {
        let noBonus: [UInt] = [0, 1, 6, 10]
        let bonus: [UInt] = [2, 3, 4, 5]

        for rank in GloryRank.allRanks {
            for wins in noBonus {
                XCTAssert(rank.winBonus(atStreakPosition: wins) == 0)
            }

            for wins in bonus {
                switch rank {
                case .guardian:
                    XCTAssert(rank.winBonus(atStreakPosition: wins) == 20)
                case .brave, .heroic, .fabled, .mythic, .legend:
                    switch wins {
                    case 2...3:
                        XCTAssert(rank.winBonus(atStreakPosition: wins) == 20)
                    case 4:
                        XCTAssert(rank.winBonus(atStreakPosition: wins) == 28)
                    case 5:
                        XCTAssert(rank.winBonus(atStreakPosition: wins) == 12)
                    default:
                        XCTAssert(rank.winBonus(atStreakPosition: wins) == 0)
                    }
                case .max:
                    XCTAssert(rank.winBonus(atStreakPosition: wins) == 0)
                }
            }
        }
    }

    func testWinPointsReturnsExpectedValues() {
        let streakPositions: [UInt] = [1, 2, 3, 4, 5, 6]

        for rank in GloryRank.allRanks {
            XCTAssert(rank.winPoints(atStreakPosition: 0) == 0)

            var bonus = 0
            for position in streakPositions {
                bonus += rank.winBonus(atStreakPosition: position)
                XCTAssert(rank.winPoints(atStreakPosition: position) == rank.baseWinPoints + bonus)
            }
        }
    }

    func testLossDeficitReturnsExpectedValues() {
        for rank in GloryRank.allRanks {
            switch rank {
            case .heroic:
                XCTAssert(rank.lossDeficit == 52)
            case .guardian, .brave, .fabled:
                XCTAssert(rank.lossDeficit == 60)
            case .mythic, .legend, .max:
                XCTAssert(rank.lossDeficit == 68)
            }
        }
    }

    func testTitleReturnsCorrectValue() {
        for rank in GloryRank.allRanks {
            switch rank {
            case .guardian:
                XCTAssert(rank.title == "Guardian")
            case .brave:
                XCTAssert(rank.title == "Brave")
            case .heroic:
                XCTAssert(rank.title == "Heroic")
            case .fabled:
                XCTAssert(rank.title == "Fabled")
            case .mythic:
                XCTAssert(rank.title == "Mythic")
            case .legend:
                XCTAssert(rank.title == "Legend")
            case .max:
                XCTAssert(rank.title == "Max")
            }
        }
    }

    func testPrettyPrintedReturnsExpectedValue() {
        for rank in GloryRank.allRanks {
            switch rank {
            case .guardian(let sub), .brave(let sub), .heroic(let sub), .fabled(let sub), .mythic(let sub):
                XCTAssert(rank.prettyPrinted == rank.title + " \(sub)")
            case .legend, .max:
                XCTAssert(rank.prettyPrinted == rank.title)
            }
        }
    }

    func testMatchCompletionBonusThresholdReturnsExpectedAmount() {
        XCTAssert(GloryRank.WeeklyMatchCompletionThreshold == 3)
    }

    func testMatchCompletionBonusAmountReturnsExpectedAmount() {
        for rank in GloryRank.allRanks {
            let bonus: Int
            
            switch rank {
            case .guardian, .brave:
                bonus = 160
            case .heroic:
                bonus = 120
            case .fabled:
                bonus = 80
            case .mythic, .legend, .max:
                bonus = 0
            }

            XCTAssert(rank.bonusGloryAmount == bonus)
        }
    }
}
