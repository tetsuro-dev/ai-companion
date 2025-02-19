import Foundation

struct ExponentialBackoff: ReconnectionStrategy {
    let initialDelay: TimeInterval
    let maxDelay: TimeInterval
    let multiplier: Double
    
    init(initialDelay: TimeInterval = 1.0, maxDelay: TimeInterval = 32.0, multiplier: Double = 2.0) {
        self.initialDelay = initialDelay
        self.maxDelay = maxDelay
        self.multiplier = multiplier
    }
    
    func nextDelay(attempt: Int) -> TimeInterval {
        let delay = initialDelay * pow(multiplier, Double(attempt))
        return min(delay, maxDelay)
    }
}
