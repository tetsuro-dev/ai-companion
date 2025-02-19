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
        guard let modelPath = Bundle.main.path(forResource: name, ofType: "model3"),
              modelBridge.loadModel(modelPath) else {
            throw Live2DError.modelLoadFailed
        }
        currentModel = model
        delegate?.live2DService(self, didLoadModel: model)
    }
    
    func updateExpression(_ expression: String) {
        modelBridge.updateExpression(expression)
    }
    
    func updateLipSync(amplitude: Float) {
        modelBridge.updateLipSync(amplitude)
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
        // Handle model loaded event
    }
    
    func onModelUpdated() {
        // Handle model update event
    }
    
    func onExpressionUpdated(_ expression: String) {
        delegate?.live2DService(self, didUpdateExpression: expression)
    }
    
    func onLipSyncUpdated(_ value: Float) {
        delegate?.live2DService(self, didUpdateLipSync: value)
    }
}
