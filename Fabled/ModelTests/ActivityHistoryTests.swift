import XCTest
@testable import Model

class ActivityHistoryTests: XCTestCase {

    func testDecodeActivityHistoryFromGetCompetitiveHistoryResponse() throws {
        let exampleResponseData =
            """
            {
                "Response": {
                    "activities": [
                        {
                            "period": "2019-07-23T22:32:25Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 0,
                                        "displayValue": "Victory"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        }
                    ]
                }
            }
            """
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .data(using: .utf8)!

        _ = try Bungie.decoder.decode(ActivityHistory.self, from: exampleResponseData)
    }

    func testDetectBrokenWinStreakFromActivityHistory() throws {
        let exampleResponseData =
            """
            {
                "Response": {
                    "activities": [
                        {
                            "period": "2019-07-28T20:08:31Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 1,
                                        "displayValue": "Defeat"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        },
                        {
                            "period": "2019-07-28T19:56:41Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 0,
                                        "displayValue": "Victory"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        }
                    ]
                }
            }
            """
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .data(using: .utf8)!

        let history = try Bungie.decoder.decode(ActivityHistory.self, from: exampleResponseData)
        XCTAssert(history.currentStreak == 0)
    }

    func testDetectNonTerminatingWinStreakFromActivityHistory() throws {
        let exampleResponseData =
            """
            {
                "Response": {
                    "activities": [
                        {
                            "period": "2019-07-28T20:08:31Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 0,
                                        "displayValue": "Victory"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        },
                        {
                            "period": "2019-07-28T19:56:41Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 0,
                                        "displayValue": "Victory"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        },
                        {
                            "period": "2019-07-28T19:44:48Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 0,
                                        "displayValue": "Victory"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        },
                        {
                            "period": "2019-07-28T19:25:51Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 0,
                                        "displayValue": "Victory"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        },
                        {
                            "period": "2019-07-23T22:32:25Z",
                            "values": {
                                "standing": {
                                    "basic": {
                                        "value": 0,
                                        "displayValue": "Victory"
                                    }
                                },
                                "activityDurationSeconds": {
                                    "basic": {
                                        "value": 373.0,
                                        "displayValue": "6m 13s"
                                    }
                                }
                            }
                        }
                    ]
                }
            }
            """
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .data(using: .utf8)!

        let history = try Bungie.decoder.decode(ActivityHistory.self, from: exampleResponseData)
        XCTAssert(history.currentStreak == 5)
    }

    func testDetectTerminatingWinStreakFromActivityHistory() throws {
        let history = generateStreakActivityHistory(for: [Date()], beginningWithLossAt: Date().rewound(m:1))
        XCTAssert(history.currentStreak == 1)
    }

    func testStreakActivitiesCountMatchesWinStreak() throws {
        let matches = (0...1).map(TimeInterval.init).map(Date.now.rewound)
        let history = generateStreakActivityHistory(for: matches)
        XCTAssert(history.streakActivities.count == history.currentStreak) //=>2
    }

    func testLatestActivityPeriodIsAccurate() {
        let period = Date(timeIntervalSinceReferenceDate: 0)
        let history = generateStreakBreakingActivityHistory(ending: period)
        XCTAssert(history.lastestActivityPeriod == period)
    }

    func testMostRecentLossPeriodReturnsExpectedValue() {
        let period = Date(timeIntervalSinceReferenceDate: 0)
        let history = generateStreakActivityHistory(for: [Date()], beginningWithLossAt: period)
        XCTAssert(history.mostRecentLossPeriod == period)
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testMatchePlayedSinceWeeklyResetReturnsExpectedValue() {
        let matches = (0...3).map(TimeInterval.init).map(Date.now.rewound)
        let history = generateStreakActivityHistory(for: matches, beginningWithLossAt: Date().rewound(m:4))
        XCTAssert(history.matchesPlayedSinceWeeklyReset == 5)
    }

    //Precondition: This test can incorrectly fail if run within a few minutes of the weekly reset (UTC Tues 17:00)
    func testWinsSinceWeeklyResetReturnsExpectedAmount() {
        let history = generateWinHistoryIntersectedByLoss()
        XCTAssert(history.winsSinceWeeklyReset == 2)
    }
}


//MARK: Helpers

/// Generate an `ActivityHistory` representing a loss.
func generateStreakBreakingActivityHistory(ending: Date = Date()) -> ActivityHistory {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime


    let jsonData =
        """
        {
            "Response": {
                "activities": [
                    {
                        "period": "\(formatter.string(from: ending))",
                        "values": {
                            "standing": {
                                "basic": {
                                    "value": 1,
                                    "displayValue": "Defeat"
                                }
                            },
                            "activityDurationSeconds": {
                                "basic": {
                                    "value": 1.0,
                                    "displayValue": "0m 1s"
                                }
                            }
                        }
                    }
                ]
            }
        }
        """
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .data(using: .utf8)!

    //Have to decode from data because Swift removed the memberwise init due to our
    //custom implementation of the decodable init.
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let string = try decoder.singleValueContainer().decode(String.self)
        return formatter.date(from: string)!
    }
    return try! decoder.decode(ActivityHistory.self, from: jsonData)
}

/// Generate an `ActivityHistory` representing a win streak across the provided periods and preceeded by a loss rewound
/// by 100 minutes before the oldest win, if not specified (assures no breaking of cross-character streaks unless desired).
func generateStreakActivityHistory(for periods: [Date], beginningWithLossAt lossPeriod: Date? = nil) -> ActivityHistory {
    guard !periods.isEmpty else { fatalError("`periods` parameter must not be empty.") }

    let lossPeriod = lossPeriod ?? periods.last!.rewound(m:100)

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime

    func generateActivity(at period: Date) -> String {
        return
            """
            {
                "period": "\(formatter.string(from: period))",
                "values": {
                    "standing": {
                        "basic": {
                            "value": 0,
                            "displayValue": "Victory"
                        }
                    },
                    "activityDurationSeconds": {
                        "basic": {
                            "value": 1.0,
                            "displayValue": "0m 1s"
                        }
                    }
                }
            }
            """
    }

    let jsonData =
        """
        {
            "Response": {
                "activities": [
                    \(periods.map(generateActivity).joined(separator: ", ")),
                    {
                        "period": "\(formatter.string(from: lossPeriod))",
                        "values": {
                            "standing": {
                                "basic": {
                                    "value": 1,
                                    "displayValue": "Defeat"
                                }
                            },
                            "activityDurationSeconds": {
                                "basic": {
                                    "value": 1.0,
                                    "displayValue": "0m 1s"
                                }
                            }
                        }
                    }
                ]
            }
        }
        """
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .data(using: .utf8)!

    //Have to decode from data because Swift removed the memberwise init due to our
    //custom implementation of the decodable init.
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let string = try decoder.singleValueContainer().decode(String.self)
        return formatter.date(from: string)!
    }
    return try! decoder.decode(ActivityHistory.self, from: jsonData)
}

private func generateWinHistoryIntersectedByLoss() -> ActivityHistory {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime

    let first = Date()
    let second = Date().rewound(m:1)
    let third = Date().rewound(m:2)

    let exampleResponseData =
        """
        {
            "Response": {
                "activities": [
                    {
                        "period": "\(formatter.string(from: first))",
                        "values": {
                            "standing": {
                                "basic": {
                                    "value": 0,
                                    "displayValue": "Victory"
                                }
                            },
                            "activityDurationSeconds": {
                                "basic": {
                                    "value": 1.0,
                                    "displayValue": "0m 1s"
                                }
                            }
                        }
                    },
                    {
                        "period": "\(formatter.string(from: second))",
                        "values": {
                            "standing": {
                                "basic": {
                                    "value": 1,
                                    "displayValue": "Defeat"
                                }
                            },
                            "activityDurationSeconds": {
                                "basic": {
                                    "value": 1.0,
                                    "displayValue": "0m 1s"
                                }
                            }
                        }
                    },
                    {
                        "period": "\(formatter.string(from: third))",
                        "values": {
                            "standing": {
                                "basic": {
                                    "value": 0,
                                    "displayValue": "Victory"
                                }
                            },
                            "activityDurationSeconds": {
                                "basic": {
                                    "value": 1.0,
                                    "displayValue": "0m 1s"
                                }
                            }
                        }
                    }
                ]
            }
        }
        """
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .data(using: .utf8)!

    //Have to decode from data because Swift removed the memberwise init due to our
    //custom implementation of the decodable init.
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let string = try decoder.singleValueContainer().decode(String.self)
        return formatter.date(from: string)!
    }
    return try! decoder.decode(ActivityHistory.self, from: exampleResponseData)
}
