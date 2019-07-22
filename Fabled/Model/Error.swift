import Foundation

public extension Bungie {
    enum Error: Swift.Error, CustomStringConvertible, LocalizedError {

        /// Occurs when Bungie.net or its API is down for maintenance.
        case systemDisabledForMaintenance

        public var description: String {
            switch self {
            case .systemDisabledForMaintenance:
                return "Bungie.net or its API is currently down for maintenance. Check help.bungie.net for status updates."
            }
        }

        public var errorDescription: String? {
            //Drop "DadKit: " from the description for presentation to the user.
            return description
        }
    }
}

public enum Error: Swift.Error {
    case noCharactersAssociatedWithPlayer
}

public enum NonFatalError: Swift.Error {
    case noActivityHistoryForCharacter
}
