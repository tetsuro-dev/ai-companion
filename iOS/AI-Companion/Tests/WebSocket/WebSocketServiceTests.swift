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
    
    func testStateTransitions() async throws {
        // Test initial state
        XCTAssertEqual(sut.state, .disconnected)
        
        // Test connecting state
        try sut.connect(to: "test/endpoint")
        XCTAssertEqual(sut.state, .connected)
        
        // Test reconnecting state
        await sut.send(Data()).catch { _ in }
        XCTAssertEqual(sut.state, .reconnecting)
        
        // Test disconnected state
        sut.disconnect()
        XCTAssertEqual(sut.state, .disconnected)
    }
    
    func testErrorConditions() async throws {
        // Test connection error
        XCTAssertThrowsError(try sut.connect(to: "")) { error in
            XCTAssertEqual(error as? WebSocketError, .invalidURL)
        }
        
        // Test send error with disconnected state
        do {
            try await sut.send(Data())
            XCTFail("Expected connectionFailed error")
        } catch {
            XCTAssertEqual(error as? WebSocketError, .connectionFailed)
        }
        
        // Test receive error with disconnected state
        do {
            _ = try await sut.receive()
            XCTFail("Expected connectionFailed error")
        } catch {
            XCTAssertEqual(error as? WebSocketError, .connectionFailed)
        }
    }
}
