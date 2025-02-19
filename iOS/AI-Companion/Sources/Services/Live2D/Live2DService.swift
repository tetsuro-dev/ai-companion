import Foundation
import Metal
import MetalKit

protocol Live2DServiceDelegate: AnyObject {
    func live2DService(_ service: Live2DService, didLoadModel model: Live2DModel)
    func live2DService(_ service: Live2DService, didUpdateExpression expression: String)
    func live2DService(_ service: Live2DService, didUpdateLipSync value: Float)
}

class Live2DService: Live2DModelDelegate {
    private let device: MTLDevice
    private let renderer: Live2DRenderer
    private let modelBridge: Live2DModelBridge
    private var viewSize: CGSize = .zero
    private var currentModel: Live2DModel?
    
    weak var delegate: Live2DServiceDelegate?
    
    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw Live2DError.rendererInitializationFailed
        }
        self.device = device
        guard let renderer = Live2DRenderer(device: device,
                                          pixelFormat: .bgra8Unorm,
                                          depthPixelFormat: .depth32Float) else {
            throw Live2DError.rendererInitializationFailed
        }
        self.renderer = renderer
        self.modelBridge = Live2DModelBridge(device: device)
        self.modelBridge.delegate = self
    }
    
    func loadModel(name: String) throws {
        let model = try Live2DModel.load(name: name)
        guard let modelPath = Bundle.main.path(forResource: name, ofType: "model3", inDirectory: "Live2D/\(name)"),
              modelBridge.loadModel(modelPath) else {
            throw Live2DError.modelLoadFailed
        }
        currentModel = model
        delegate?.live2DService(self, didLoadModel: model)
        
        // Start with neutral expression
        updateExpression("neutral")
    }
    
    func updateExpression(_ expression: String) async throws {
        guard let model = currentModel,
              let motionFile = model.getMotionFile(for: expression) else {
            return
        }
        
        modelBridge.updateExpression(expression)
        
        // Load and play the corresponding motion
        if let motionPath = Bundle.main.path(forResource: motionFile, ofType: nil, inDirectory: "Live2D/\(model.modelName)/motion") {
            renderer.loadMotion(motionPath)
        }
        
        // Send avatar expression event via WebSocket
        try await WebSocketService.shared.sendAvatarExpression(expression)
    }
    
    func updateLipSync(amplitude: Float) async throws {
        modelBridge.updateLipSync(amplitude)
        
        // Send lip sync event via WebSocket
        try await WebSocketService.shared.sendAvatarLipSync(amplitude)
    }
    
    func updateViewSize(_ size: CGSize) {
        viewSize = size
        renderer.updateWithSize(size)
    }
    
    func render(in view: MTKView, commandBuffer: MTLCommandBuffer) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderer.render(commandBuffer,
                       texture: view.currentDrawable?.texture,
                       renderPass: renderPassDescriptor,
                       viewSize: viewSize)
    }
    
    func update(deltaTime: CFTimeInterval) {
        modelBridge.update(deltaTime)
        renderer.updateAnimations(deltaTime)
    }
    
    // MARK: - Live2DModelDelegate
    
    func onModelLoaded() {
        // Start idle animation after model is loaded
        updateExpression("idle")
    }
    
    func onModelUpdated() {
        // Handle model update event
    }
    
    func onExpressionUpdated(_ expression: String) {
        currentModel?.currentExpression = expression
        delegate?.live2DService(self, didUpdateExpression: expression)
    }
    
    func onLipSyncUpdated(_ value: Float) {
        delegate?.live2DService(self, didUpdateLipSync: value)
    }
}
