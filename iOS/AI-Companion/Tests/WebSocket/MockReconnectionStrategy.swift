import Foundation
@testable import AI_Companion

class MockReconnectionStrategy: ReconnectionStrategy {
    var nextDelayToReturn: TimeInterval = 1.0
    var attemptsCalled: [Int] = []
    
    func nextDelay(attempt: Int) -> TimeInterval {
        attemptsCalled.append(attempt)
        return nextDelayToReturn
    }
}
