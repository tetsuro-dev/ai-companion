import Foundation

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case reconnecting
}

protocol ReconnectionStrategy {
    func nextDelay(attempt: Int) -> TimeInterval
}
