import XCTest
@testable import AI_Companion

class WebSocketServiceTests: XCTestCase {
    var sut: WebSocketService!
    var mockStrategy: MockReconnectionStrategy!
    
    override func setUp() {
        super.setUp()
        mockStrategy = MockReconnectionStrategy()
        sut = WebSocketService(reconnectionStrategy: mockStrategy)
    }
    
    override func tearDown() {
        sut = nil
        mockStrategy = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(sut.state, .disconnected)
    }
    
    func testConnectChangesState() throws {
        try sut.connect(to: "test/endpoint")
        XCTAssertEqual(sut.state, .connected)
    }
    
    func testDisconnectChangesState() throws {
        try sut.connect(to: "test/endpoint")
        sut.disconnect()
        XCTAssertEqual(sut.state, .disconnected)
    }
    
    func testInvalidURLThrowsError() {
        XCTAssertThrowsError(try sut.connect(to: " ")) { error in
            XCTAssertTrue(error is WebSocketError)
            XCTAssertEqual(error as? WebSocketError, .invalidURL)
        }
    }
    
    func testReconnectionAfterFailure() async throws {
        try sut.connect(to: "test/endpoint")
        
        // Simulate failure and reconnection
        await sut.send(Data()).catch { _ in }
        
        // Verify reconnection attempt
        XCTAssertEqual(sut.state, .reconnecting)
        XCTAssertTrue(mockStrategy.attemptsCalled.contains(0))
    }
    
    func testNetworkInterruption() async throws {
        try sut.connect(to: "test/endpoint")
        XCTAssertEqual(sut.state, .connected)
        
        // Simulate network interruption
        await sut.receive().catch { error in
            XCTAssertTrue(error is WebSocketError)
        }
        
        XCTAssertEqual(sut.state, .reconnecting)
    }
    
    func testNormalClosure() {
        // Test normal disconnection
        try? sut.connect(to: "test/endpoint")
        sut.disconnect()
        
        XCTAssertEqual(sut.state, .disconnected)
        XCTAssertNil(sut.webSocketTask)
    }
    
    func testMultipleReconnectionAttempts() async throws {
        try sut.connect(to: "test/endpoint")
        
        // Simulate multiple failures
        for _ in 0..<3 {
            await sut.send(Data()).catch { _ in }
        }
        
        // Verify increasing delays
        XCTAssertEqual(mockStrategy.attemptsCalled.count, 3)
        XCTAssertEqual(sut.state, .reconnecting)
    }
    
    func testExponentialBackoff() {
        let strategy = ExponentialBackoff(initialDelay: 1.0, maxDelay: 8.0, multiplier: 2.0)
        
        XCTAssertEqual(strategy.nextDelay(attempt: 0), 1.0)
        XCTAssertEqual(strategy.nextDelay(attempt: 1), 2.0)
        XCTAssertEqual(strategy.nextDelay(attempt: 2), 4.0)
        XCTAssertEqual(strategy.nextDelay(attempt: 3), 8.0)
        XCTAssertEqual(strategy.nextDelay(attempt: 4), 8.0) // Max delay reached
    }
}
