import XCTest
@testable import Model

class ProfileTests: XCTestCase {
//    private var exampleProfileResponseData: Data!

    func testProfileDetectsSingleCharacterWinStreak() {
        let wins = [Date()] //=>1

        let history = generateStreakActivityHistory(for: wins)
        let profile = generateProfile(with: [history])

        XCTAssert(profile.currentWinStreak == wins.count)
    }

    func testProfileDetectsCumulativeWinStreakAcrossMultipleCharacters() {
        let wins = [[Date()], [Date().rewound(m:1)]] //=>2

        let firstCharacter = generateStreakActivityHistory(for: wins[0])
        let secondCharacter = generateStreakActivityHistory(for: wins[1])

        let profile = generateProfile(with: [firstCharacter, secondCharacter])

        XCTAssert(profile.currentWinStreak == wins.count)
    }

    func testProfileDetectsNoStreak() {
        let history = generateStreakBreakingActivityHistory()
        let profile = generateProfile(with: [history])

        XCTAssert(profile.currentWinStreak == 0)
    }

    func testProfileDetectsBrokenStreakStartedFromAnotherCharacter() {
        let firstCharacter = generateStreakBreakingActivityHistory(ending: Date())
        let secondCharacter = generateStreakActivityHistory(for: [Date().rewound(m:1)])

        let profile = generateProfile(with: [firstCharacter, secondCharacter])

        XCTAssert(profile.currentWinStreak == 0) //∵ newer loss erases older win
    }

    func testProfileDetectsWinStreakIgnoringOlderLossFromAnotherCharacter() {
        let firstCharacter = generateStreakActivityHistory(for: [Date()])
        let secondCharacter = generateStreakBreakingActivityHistory(ending: Date().rewound(m:1))

        let profile = generateProfile(with: [firstCharacter, secondCharacter])

        XCTAssert(profile.currentWinStreak == 1) //∵ newer win ignores older loss
    }

    func testProfileDetectsWinStreakIntersectedByLossFromAnotherCharacter() {
        let wins = [Date(), Date().rewound(m:2)]
        let loss = Date().rewound(m:1)

        let firstCharacter = generateStreakActivityHistory(for: wins)
        let secondCharacter = generateStreakBreakingActivityHistory(ending: loss)

        let profile = generateProfile(with: [firstCharacter, secondCharacter])

        XCTAssert(profile.currentWinStreak == 1) //∵ loss chronologicaly occurred between wins
    }

    func testProfileDetectsWinStreakIgnoringStreakPredatingMostRecentLoss() {
        let wins = [
            [Date(), Date().rewound(m:1)],
            [Date().rewound(m:2), Date().rewound(m:3)],
            [Date().rewound(m:5), Date().rewound(m:6)]
        ]

        let firstCharacter = generateStreakActivityHistory(for: wins[0])
        let secondCharacter = generateStreakActivityHistory(for: wins[1], beginningWithLossAt: Date().rewound(m:4))
        let thirdCharacter = generateStreakActivityHistory(for: wins[2])

        let profile = generateProfile(with: [firstCharacter, secondCharacter, thirdCharacter])

        XCTAssert(profile.currentWinStreak == 4) //∵ secondCharacter's loss occurred after thirdCharacter's wins
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testMatchesPlayedThisWeekReturnsCorrectAmount() {
        XCTAssert(generateProfile().matchesPlayedThisWeek == 0)

        for matchCount in 1...5 {
            let matches = (1...matchCount).map(TimeInterval.init).map(Date.now.rewound)
            let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date.distantPast)
            let profile = generateProfile(with: [history])

            XCTAssert(profile.matchesPlayedThisWeek == matchCount)
        }
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testMatchesPlayedThisWeekReturnsCorrectAmountAcrossMultipleCharacters() {
        let character1 = generateStreakActivityHistory(for: [Date()], beginningWithLossAt: Date().rewound(m: 1))
        let character2 = generateStreakBreakingActivityHistory(ending: Date().rewound(m:2))
        let character3 = generateStreakActivityHistory(for: [Date().rewound(m:3)], beginningWithLossAt: Date().rewound(m:4))
        let profile = generateProfile(with: [character1, character2, character3])

        XCTAssert(profile.matchesPlayedThisWeek == 5)
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testMatchesWonThisWeekReturnsCorrectAmount() {
        XCTAssert(generateProfile().matchesWonThisWeek == 0)

        for matchCount in 1...5 {
            let matches = (1...matchCount).map(TimeInterval.init).map(Date.now.rewound)
            let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date().rewound(m:TimeInterval(matchCount + 1)))
            let profile = generateProfile(with: [history])

            XCTAssert(profile.matchesWonThisWeek == matchCount)
        }
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testMatchesWonThisWeekReturnsCorrectAmountAcrossMultipleCharacters() {
        let character1 = generateStreakActivityHistory(for: [Date()], beginningWithLossAt: Date().rewound(m: 1))
        let character2 = generateStreakBreakingActivityHistory(ending: Date().rewound(m:2))
        let character3 = generateStreakActivityHistory(for: [Date().rewound(m:3)], beginningWithLossAt: Date().rewound(m:4))
        let profile = generateProfile(with: [character1, character2, character3])

        XCTAssert(profile.matchesWonThisWeek == 2)
    }

    func testMatchesRemainingForWeeklyBonusReturnsZeroWhenMatchBonusThresholdHasBeenMet() {
        let matches = (1...2).map(TimeInterval.init).map(Date.now.rewound)
        let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date().rewound(m:3))
        let profile = generateProfile(with: [history])

        XCTAssert(profile.matchesRemainingToWeeklyThreshold == 0)
    }

    func testMatchesRemainingForWeeklyBonusReturnsCorrectAmount() {
        for matchCount in 1...3 {
            let matches = (1...matchCount).map(TimeInterval.init).map(Date.now.rewound)
            let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date.distantPast)
            let profile = generateProfile(with: [history])

            XCTAssert(profile.matchesRemainingToWeeklyThreshold == GloryRank.WeeklyMatchCompletionThreshold - matchCount)
        }
    }

    func testProfileReturnsExpectedRank() {
        let rank = GloryRank.brave(.I)
        let profile = generateProfile(at: rank)
        XCTAssert(profile.rank == rank)
    }

    func testProfileReturnsExpectedRankWithOffsetGlory() {
        let rank = GloryRank.brave(.I)
        let profile = generateProfile(at: rank, progressOffset: UInt(rank.pointLength - 1))
        XCTAssert(profile.rank == rank)
    }

    func testProfileReturnsExpectedRankWithOffsetGloryResultingInRankup() {
        //This is mostly a test of `generateProfile` and is not really applicable to the Bungie.net API
        let rank = GloryRank.brave(.I)
        let profile = generateProfile(at: rank, progressOffset: UInt(rank.pointLength))
        XCTAssert(profile.rank == .brave(.II))
    }

    func testProfileReturnsExpectedRankText() {
        for rank in GloryRank.allRanks {
            XCTAssert(generateProfile(at: rank).rankText == rank.prettyPrinted)
        }
    }

    func testProfileReturnsExpectedGloryToNextRank() {
        let rank = GloryRank.brave(.I)
        let progress = 1
        let gloryToNextRank = rank.pointLength - progress
        let profile = generateProfile(at: rank, progressOffset: UInt(progress))
        XCTAssert(profile.gloryToNextRank == gloryToNextRank)
    }

    func testWinsToNextRankReturnsZeroWhenAtMaxRank() {
        let profile = generateProfile(at: .max)
        XCTAssert(profile.winsToNextRank == 0)
    }

    func testWinsToFabledReturnsZeroWhenAboveFabledRank() {
        let profile = generateProfile(at: .fabled(.I))
        XCTAssert(profile.winsToFabled == 0)
    }

    //22 second regression/redundancy test so disabled in the scheme -- run manually
    func testWinsToNextRankReturnsExpectedValue() {
        for points in 0...(GloryRank.max.endingGlory - 1) {
            for streakPosition in 1...5 {
                let rank = GloryRank(points: points)
                let progressToNextRank = points - rank.startingGlory
                let distanceToNextRank = rank.pointLength

                var wins = UInt(streakPosition)
                var pointProgress = progressToNextRank

                while pointProgress < distanceToNextRank {
                    wins += 1
                    pointProgress += rank.winPoints(atStreakPosition: wins)
                }

                let streak = (1...streakPosition).map(TimeInterval.init).map(Date.now.rewound)
                let histories = generateStreakActivityHistory(for: streak)
                let profile = generateProfile(with: [histories], at: rank, progressOffset: UInt(progressToNextRank))

                XCTAssert(profile.winsToNextRank == wins - profile.currentWinStreak)
            }
        }
    }

    func testWinsToNextRankAlwaysReturnsOneWhenWithinOneWinRegardlessOfStreak() {
        let rank = GloryRank.heroic(.I)
        let onePointLeft = UInt(rank.pointLength - 1)

        func history(_ streak: Int) -> ActivityHistory {
            guard streak > 0 else { return generateStreakBreakingActivityHistory() }
            let streak = (1...streak).map(TimeInterval.init).map(Date.now.rewound)
            return generateStreakActivityHistory(for: streak)
        }

        for streakPosition in 0...4 {
            let profile = generateProfile(with: [history(streakPosition)], at: rank, progressOffset: onePointLeft)
            XCTAssert(profile.winsToNextRank == 1)
        }
    }

    func testWinsToNextRank_Arbitrary1() {
        let rank = GloryRank.brave(.II)
        let progress: UInt = 11
        let results = [4, 3, 3, 2, 2]

        func history(_ streak: Int) -> ActivityHistory {
            guard streak > 0 else { return generateStreakBreakingActivityHistory() }
            let streak = (1...streak).map(TimeInterval.init).map(Date.now.rewound)
            return generateStreakActivityHistory(for: streak)
        }

        for (streakPosition, result) in results.enumerated() {
            let profile = generateProfile(with: [history(streakPosition)], at: rank, progressOffset: progress)
            XCTAssert(profile.winsToNextRank == result)
        }
    }

    func testWinsToNextRank_Arbitrary2() {
        let rank = GloryRank.heroic(.III)
        let progress: UInt = 55
        let results = [5, 4, 4, 4, 3]

        func history(_ streak: Int) -> ActivityHistory {
            guard streak > 0 else { return generateStreakBreakingActivityHistory() }
            let streak = (1...streak).map(TimeInterval.init).map(Date.now.rewound)
            return generateStreakActivityHistory(for: streak)
        }

        for (streakPosition, result) in results.enumerated() {
            let profile = generateProfile(with: [history(streakPosition)], at: rank, progressOffset: progress)
            XCTAssert(profile.winsToNextRank == result)
        }
    }

    func testWinsToNextRank_Arbitrary3() {
        let rank = GloryRank.mythic(.III)
        let results = [10, 9, 8, 8, 8]

        func history(_ streak: Int) -> ActivityHistory {
            guard streak > 0 else { return generateStreakBreakingActivityHistory() }
            let streak = (1...streak).map(TimeInterval.init).map(Date.now.rewound)
            return generateStreakActivityHistory(for: streak)
        }

        for (streakPosition, result) in results.enumerated() {
            let profile = generateProfile(with: [history(streakPosition)], at: rank)
            XCTAssert(profile.winsToNextRank == result)
        }
    }

    func testWinsToNextRank_Arbitrary4() {
        let rank = GloryRank.legend
        let results = [2, 1, 1, 1, 1]

        func history(_ streak: Int) -> ActivityHistory {
            guard streak > 0 else { return generateStreakBreakingActivityHistory() }
            let streak = (1...streak).map(TimeInterval.init).map(Date.now.rewound)
            return generateStreakActivityHistory(for: streak)
        }

        for (streakPosition, result) in results.enumerated() {
            let profile = generateProfile(with: [history(streakPosition)], at: rank)
            XCTAssert(profile.winsToNextRank == result)
        }
    }

    func testWinsToFabledIsEqualToWinsToNextRankWhenFabledIsNextRank() {
        let profile = generateProfile(at: .heroic(.III))
        XCTAssert(profile.winsToFabled == profile.winsToNextRank)
    }

    //16 second regression/redundancy test so disabled in the scheme -- run manually
    func testWinsToFabledReturnsExpectedValue() {
        let fabledPoints = GloryRank.fabled(.I).startingGlory

        for points in 0...(fabledPoints - 1) {
            for streakPosition in 1...5 {
                let currentRank = GloryRank(points: points)
                let progressToNextRank = points - currentRank.startingGlory

                var wins = UInt(streakPosition)
                var pointProgress = points
                var rank = currentRank

                while pointProgress < fabledPoints {
                    wins += 1
                    pointProgress += rank.winPoints(atStreakPosition: wins)
                    rank = GloryRank(points: pointProgress)
                }

                let streak = (1...streakPosition).map(TimeInterval.init).map(Date.now.rewound)
                let histories = generateStreakActivityHistory(for: streak)
                let profile = generateProfile(with: [histories], at: currentRank, progressOffset: UInt(progressToNextRank))

                XCTAssert(profile.winsToFabled == wins - profile.currentWinStreak)
            }
        }
    }

    func testWinsToFabled_Arbitrary1() {
        let rank = GloryRank.brave(.II)
        let progress: UInt = 94 //Lands exactly on 2100
        let streakPosition = 3

        let streak = (1...streakPosition).map(TimeInterval.init).map(Date.now.rewound)
        let history = generateStreakActivityHistory(for: streak)
        let profile = generateProfile(with: [history], at: rank, progressOffset: progress)

        XCTAssert(profile.winsToFabled == 12)
    }

    func testWinsToFabled_Arbitrary2() {
        let rank = GloryRank.heroic(.I)
        let progress: UInt = 122 //Lands exactly on 2100

        let history = generateStreakBreakingActivityHistory()
        let profile = generateProfile(with: [history], at: rank, progressOffset: progress)

        XCTAssert(profile.winsToFabled == 8)
    }

    func testWinsToFabled_Arbitrary3() {
        let rank = GloryRank.guardian(.I)
        let points: UInt = 104 //Lands exactly on 2100

        let history = generateStreakBreakingActivityHistory()
        let profile = generateProfile(with: [history], at: rank, progressOffset: points)

        XCTAssert(profile.winsToFabled == 15)
    }

    func testWinsToFabledEquals16WhenStartingFromZero() {
        let rank = GloryRank.guardian(.I)

        let history = generateStreakBreakingActivityHistory()
        let profile = generateProfile(with: [history], at: rank)

        XCTAssert(profile.winsToFabled == 16)
    }

    func testWinsToFabledWaitingForWeeklyBonusAccountsForBonusAmount() {
        let rank = GloryRank(for: GloryRank.fabled(.I).level - 1)
        let progress = rank.pointLength - rank.bonusGloryAmount - rank.baseWinPoints //=> 1 win remaining
        let history = generateStreakBreakingActivityHistory()
        let profile = generateProfile(with: [history], at: rank, progressOffset: UInt(progress))

        XCTAssert(profile.winsToFabled(waitingForWeeklyBonus: true) == 1)
    }

    func testWinsToFabledWaitingForWeeklyBonusReturnsZeroWhenPastBonusThreshold() {
        let rank = GloryRank(for: GloryRank.fabled(.I).level - 1)
        let progress = rank.pointLength - 1
        let profile = generateProfile(at: rank, progressOffset: UInt(progress))

        XCTAssert(profile.winsToFabled(waitingForWeeklyBonus: true) == 0)
    }

    func testHasMetBonusRequirementThisWeekReturnsFalseWhenProfileHasInsufficientPlayerActivity() {
        let history = generateStreakBreakingActivityHistory()
        let profile = generateProfile(with: [history])

        XCTAssertFalse(profile.hasMetThresholdRequirementThisWeek) //=> 1 game
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testHasMetBonusRequirementThisWeekReturnsTrueWhenProfileHasSufficientPlayerActivity() {
        let matches = (1...2).map(TimeInterval.init).map(Date.now.rewound)
        let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date.now.rewound(m:3))
        let profile = generateProfile(with: [history])

        XCTAssert(profile.hasMetThresholdRequirementThisWeek) //=> 3 matches
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testHasMetBonusRequirementThisWeekDetectsGamesAcrossMultipleCharacters() {
        let character1 = generateStreakActivityHistory(for: [Date()], beginningWithLossAt: Date().rewound(m: 1))
        let character2 = generateStreakBreakingActivityHistory(ending: Date().rewound(m:2))
        let character3 = generateStreakActivityHistory(for: [Date().rewound(m:3)], beginningWithLossAt: Date().rewound(m:4))
        let profile = generateProfile(with: [character1, character2, character3])

        XCTAssert(profile.hasMetThresholdRequirementThisWeek) //=> 5 matches
    }

    func testGloryAtNextWeeklyResetReturnsExpectedAmountWhenBonusThresholdHasNotBeenMet() {
        let profile = generateProfile()
        XCTAssert(profile.gloryAtNextWeeklyReset == profile.glory.currentProgress)
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testGloryAtNextWeeklyResetReturnsExpectedAmountWhenBonusThresholdHasBeenMet() {
        let matches = (1...2).map(TimeInterval.init).map(Date.now.rewound)
        let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date.now.rewound(m:3)) //=> 3 matches
        let profile = generateProfile(with: [history])

        XCTAssert(profile.gloryAtNextWeeklyReset == profile.glory.currentProgress + profile.rank.bonusGloryAmount)
    }

    func testMinimumGloryAtNextWeeklyResetEqualsGloryAtNextWeeklyResetWhenBonusThresholdHasBeenMet() {
        let matches = (1...2).map(TimeInterval.init).map(Date.now.rewound)
        let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date.now.rewound(m:3)) //=> 3 matches
        let profile = generateProfile(with: [history])

        XCTAssert(profile.minimumGloryAtNextWeeklyReset(winningNextMatch: false) == profile.gloryAtNextWeeklyReset)
    }

    func testPessimisticGloryAtNextWeeklyResetReturnsExpectedAmountWithNoMatchesYetPlayed() {
        let rank = GloryRank.heroic(.III)
        let profile = generateProfile(at: rank, progressOffset: 200) //ensures no profile rank-down with losses

        let lossDeficit = rank.lossDeficit * 3
        let expectedAmount: Int = profile.glory.currentProgress - lossDeficit + rank.bonusGloryAmount

        XCTAssert(profile.pessimisticGloryAtNextWeeklyReset == expectedAmount)
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testPessimisticGloryAtNextWeeklyResetReturnsExpectedAmountWithMatchesPlayed() {
        let rank = GloryRank.heroic(.III)

        for gamesPlayed in 1...2 {
            let matches = (1...gamesPlayed).map(TimeInterval.init).map(Date.now.rewound)
            let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date.distantPast)
            let profile = generateProfile(with: [history], at: rank, progressOffset: 200) //ensures no profile rank-down with losses

            let remainingGames = 3 - gamesPlayed
            let lossDeficit = rank.lossDeficit * remainingGames
            let expectedAmount: Int = profile.glory.currentProgress - lossDeficit + rank.bonusGloryAmount

            XCTAssert(profile.pessimisticGloryAtNextWeeklyReset == expectedAmount)
        }
    }

    func testPessimisticGloryAtNextWeeklyResetReturnsExpectedAmountWithRankChange() {
        let rank = GloryRank.heroic(.I)
        let rankDown = GloryRank(for: rank.level - 1)
        let progress = rank.lossDeficit - 1
        let profile = generateProfile(at: rank, progressOffset: UInt(progress))

        let lossDeficit = rank.lossDeficit + rankDown.lossDeficit * 2
        let expectedAmount: Int = profile.glory.currentProgress - lossDeficit + rankDown.bonusGloryAmount

        XCTAssert(profile.pessimisticGloryAtNextWeeklyReset == expectedAmount)
    }

    func testOptimisticGloryAtNextWeeklyResetReturnsExpectedAmountWithNoMatchesYetPlayed() {
        let rank = GloryRank.heroic(.III)
        let profile = generateProfile(at: rank, progressOffset: 200) //ensures no profile rank-down with losses

        let lossDeficit = rank.lossDeficit * 2
        let expectedAmount: Int = profile.glory.currentProgress + rank.baseWinPoints - lossDeficit + rank.bonusGloryAmount

        XCTAssert(profile.optimisticGloryAtNextWeeklyReset == expectedAmount)
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testOptimisticGloryAtNextWeeklyResetReturnsExpectedAmountWithMatchesPlayedWithoutWinStreak() {
        let rank = GloryRank.heroic(.III)

        for gamesPlayed in 1...2 {
            let matches = (1...gamesPlayed).map(TimeInterval.init).map(Date.now.rewound).map(generateStreakBreakingActivityHistory)
            let profile = generateProfile(with: matches, at: rank, progressOffset: 200) //ensures no profile rank-down with losses

            let remainingGames = 2 - gamesPlayed
            let lossDeficit = rank.lossDeficit * remainingGames
            let expectedAmount: Int = profile.glory.currentProgress + rank.baseWinPoints - lossDeficit + rank.bonusGloryAmount

            XCTAssert(profile.optimisticGloryAtNextWeeklyReset == expectedAmount)
        }
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testOptimisticGloryAtNextWeeklyResetReturnsExpectedAmountWithMatchesPlayedWithWinStreak() {
        let rank = GloryRank.heroic(.III)

        for gamesPlayed in 1...2 {
            let matches = (1...gamesPlayed).map(TimeInterval.init).map(Date.now.rewound)
            let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date.distantPast)
            let profile = generateProfile(with: [history], at: rank, progressOffset: 200) //ensures no profile rank-down with losses

            let remainingGames = 2 - gamesPlayed
            let lossDeficit = rank.lossDeficit * remainingGames
            let winPoints = rank.winPoints(atStreakPosition: UInt(gamesPlayed + 1))
            let expectedAmount: Int = profile.glory.currentProgress + winPoints - lossDeficit + rank.bonusGloryAmount

            XCTAssert(profile.optimisticGloryAtNextWeeklyReset == expectedAmount)
        }
    }

    func testOptimisticGloryAtNextWeeklyResetReturnsExpectedAmountWithRankChange() {
        let rank = GloryRank.guardian(.III)
        let rankUp = GloryRank(for: rank.level + 1)
        let progress = rank.pointLength - 1
        let profile = generateProfile(at: rank, progressOffset: UInt(progress))

        let lossDeficit = rankUp.lossDeficit * 2
        let expectedAmount: Int = profile.glory.currentProgress + rank.baseWinPoints - lossDeficit + rank.bonusGloryAmount

        XCTAssert(profile.optimisticGloryAtNextWeeklyReset == expectedAmount)
    }

    func testWillRankUpAtResetReturnsTrue() {
        //`willRankUpAtReset` uses `optimisticGloryAtNextWeeklyReset` and therefore shares its test coverage
        let rank = GloryRank.heroic(.III)
        let profile = generateProfile(at: rank, progressOffset: UInt(rank.pointLength - 1))
        XCTAssert(profile.willRankUpAtReset)
    }

    func testWillRankUpAtResetReturnsFalse() {
        //`willRankUpAtReset` uses `optimisticGloryAtNextWeeklyReset` and therefore shares its test coverage
        XCTAssertFalse(generateProfile().willRankUpAtReset)
    }
}


//MARK: Helpers

/// Generate a `Profile` using the provided activity histories, optionally at a specified `GloryRank` and Glory point offset.
/// Offset is relative to the `rank`'s base Glory.
private func generateProfile(with histories: [ActivityHistory] = [], at rank: GloryRank = .heroic(.I), progressOffset: UInt = 0) -> Profile {
    //Technically `offsetProgress` should factor in +/- Glory from `histories` but that's too many implicit variables for our tests.
    let offsetProgress = rank.startingGlory + Int(progressOffset)
    let offsetRank = GloryRank(points: offsetProgress)

    return
        Profile(
            player: Player(
                displayName: "WeirdRituals",
                membershipType: Bungie.Platform.blizzard.rawValue,
                membershipId: "4611686018468167462"),
            glory: Progression(
                dailyProgress: 0,
                weeklyProgress: 0,
                currentProgress: offsetProgress,
                level: offsetRank.level,
                progressToNextLevel: offsetProgress - offsetRank.startingGlory,
                nextLevelAt: offsetRank.pointLength),
            activityHistories: histories)
}

//extention ProfileTests {
//    override func setUp() {
//        exampleProfileResponseData =
//        """
//        {
//            "Response": {
//                "profile": {
//                    "data": {
//                        "userInfo": {
//                            "membershipType": 4,
//                            "membershipId": "4611686018468167462",
//                            "displayName": "WeirdRituals"
//                        },
//                        "characterIds": [
//                            "2305843009301040747",
//                            "2305843009350194973",
//                            "2305843009355954197"
//                        ]
//                    }
//                },
//                "characterProgressions": {
//                    "data": {
//                        "2305843009301040747": {
//                            "progressions": {
//                                "2000925172": {
//                                    "progressionHash": 2000925172,
//                                    "dailyProgress": 0,
//                                    "dailyLimit": 0,
//                                    "weeklyProgress": 0,
//                                    "weeklyLimit": 0,
//                                    "currentProgress": 2184,
//                                    "level": 9,
//                                    "levelCap": 0,
//                                    "stepIndex": 9,
//                                    "progressToNextLevel": 84,
//                                    "nextLevelAt": 280
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        """
//        .trimmingCharacters(in: .whitespacesAndNewlines)
//        .data(using: .utf8)
//    }
//}

extension Date {
    /// Alias for `.init()`
    static var now: Date {
        return .init()
    }

    /// Returns the date rewound by the provided number of minutes.
    func rewound(m minutes: TimeInterval) -> Date {
        guard minutes > 0 else { return self }
        return addingTimeInterval(-60 * minutes)
    }
}
