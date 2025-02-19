import Foundation
import SwiftUI
import MetalKit

@MainActor
final class Live2DViewModel: ObservableObject {
    static let shared = try! Live2DViewModel()
    
    @Published private(set) var currentExpression: String = "neutral"
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lipSyncValue: Float = 0
    
    private let live2DService: Live2DService
    private var lipSyncTask: Task<Void, Never>?
    private var currentModel: Live2DModel?
    
    init() throws {
        self.live2DService = try Live2DService()
        self.live2DService.delegate = self
    }
    
    func loadModel(name: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try live2DService.loadModel(name: name)
    }
    
    func updateExpression(_ expression: String) async {
        try? await live2DService.updateExpression(expression)
    }
    
    func updateLipSync(amplitude: Float) async {
        lipSyncValue = min(max(amplitude, 0), 1)
        try? await live2DService.updateLipSync(amplitude: lipSyncValue)
    }
    
    func stopLipSync() {
        lipSyncTask?.cancel()
        lipSyncTask = nil
        Task {
            await updateLipSync(amplitude: 0)
        }
    }
    
    func updateViewSize(_ size: CGSize) {
        live2DService.updateViewSize(size)
    }
    
    func render(in view: MTKView, commandBuffer: MTLCommandBuffer) {
        live2DService.render(in: view, commandBuffer: commandBuffer)
    }
    
    func update(deltaTime: CFTimeInterval) {
        live2DService.update(deltaTime: deltaTime)
    }
}

// MARK: - Live2DServiceDelegate
extension Live2DViewModel: Live2DServiceDelegate {
    func live2DService(_ service: Live2DService, didLoadModel model: Live2DModel) {
        currentModel = model
    }
    
    func live2DService(_ service: Live2DService, didUpdateExpression expression: String) {
        currentExpression = expression
    }
    
    func live2DService(_ service: Live2DService, didUpdateLipSync value: Float) {
        // Handle lip sync update if needed
    }
}
