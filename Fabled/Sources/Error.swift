import Foundation
import UIKit.UIAlertController

/// Errors presentable to the user as messages.
enum Error: LocalizedError, CustomStringConvertible {

    /// Just your standard, super unhelpful error message.
    case genericUserFacing

    /// For when the real error was a `DecodingError`
    case modelDecodingFailed

    /// For when we get a bad status code on our request responses.
    case badHTTPResponse

    /// Used to let the user know that our Glory predictions are currently broken due to changes
    /// associated with the launch of Shadowkeep.
    ///
    /// Not a real error, but it's temporary and easier to encapsulate the message as an error for now.
    case shadowkeepLaunched

    var errorDescription: String {
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
        case .shadowkeepLaunched:
            return """
            Unfortunately, our Glory and rank-up predictions are no longer accurate due to the \
            Glory changes that came with Shadowkeep. We are working to update, and will \
            remove this banner once we have the new system figured out.\n\nWe're sorry!
            """
        }
    }
}

/// A collection of values used for presenting an error message to a user.
protocol PresentableError: Swift.Error {
    /// The title of the message to display.
    var title: String { get }

    /// The body of the message to display.
    var body: String { get }

    /// The text of the no-op user response action (i.e. the `.cancel` action).
    var response: String { get }

    /// A secondary response action to provide to the user, if desired.
    var customResponse: UIAlertAction? { get }

    /// Indicates that the error is appropriate for reporting to the Fabled Issues tracker.
    /// Overrides `customResponse`, if present.
    var reportable: Bool { get }
}

extension PresentableError {
    /// Generates a new `UIAlertController` object that is appropriate for displaying this error to the user.
    ///
    /// The returned object is not automatically displayed and must be presented by the caller.
    func alert() -> UIAlertController {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(.init(title: response, style: .cancel))

        if reportable {
            alert.addAction(.init(title: "Report", style: .default) { _ in
                UIApplication.shared.open(URL(string: "https://github.com/nathanhosselton/Fabled/issues")!)
            })
        } else if let customResponse = customResponse {
            alert.addAction(customResponse)
        }

        return alert
    }
}

extension Fabled.Error: PresentableError {
    var title: String {
        switch self {
        case .shadowkeepLaunched:
            return "Hey there"
        case .modelDecodingFailed:
            return "Dangit"
        default:
            return "Hmmm…"
        }
    }

    var body: String {
        return errorDescription
    }

    var response: String {
        switch self {
        case .shadowkeepLaunched:
            return "OK"
        case .modelDecodingFailed:
            return "Cancel"
        case .badHTTPResponse:
            return "no u"
        default:
            return "Lame but ok"
        }
    }

    var customResponse: UIAlertAction? {
        switch self {
        case .shadowkeepLaunched:
            return UIAlertAction(title: "Read More", style: .default) { _ in
                UIApplication.shared.open(URL(string: "https://github.com/nathanhosselton/Fabled/blob/master/README.md#re-shadowkeep")!)
            }
        default:
            return nil
        }
    }

    var reportable: Bool {
        switch self {
        case .modelDecodingFailed, .genericUserFacing:
            return true
        default:
            return false
        }
    }
}

import Model

extension Bungie.Error: PresentableError {
    var title: String { "Welp" }

    var body: String { description }

    var response: String { "Thanks Bungo" }

    var customResponse: UIAlertAction? { nil }

    var reportable: Bool { false }
}
