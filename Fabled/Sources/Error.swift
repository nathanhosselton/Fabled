import Foundation

/// Errors presentable to the user as messages.
enum Error: LocalizedError, CustomStringConvertible {

    /// Just your standard, super unhelpful error message.
    case genericUserFacing

    /// For when the real error was a `DecodingError`
    case modelDecodingFailed

    /// For when we get a bad status code on our request responses.
    case badHTTPResponse

    var errorDescription: String? {
        return description
    }

    var description: String {
        switch self {
        case .genericUserFacing:
            return "Something went wrong. Sorry, we got nothing else for you. Try again in a few. If it persists, reporting it would be helpful for us."
        case .modelDecodingFailed:
            return "We screwed up. Trying again may not fix it. Reporting this along with your player name would be helpful for us."
        case .badHTTPResponse:
            return "We tried to reach out to Bungie but got the cold shoulder. Check your internet connection or try again in a few."
        }
    }
}
