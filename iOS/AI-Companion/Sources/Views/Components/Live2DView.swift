import SwiftUI
import MetalKit

struct Live2DView: UIViewRepresentable {
    @ObservedObject var viewModel: Live2DViewModel
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.drawableSize = mtkView.frame.size
        
        viewModel.updateViewSize(mtkView.frame.size)
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        viewModel.updateViewSize(uiView.frame.size)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: Live2DView
        private var lastFrameTime: CFTimeInterval = 0
        
        init(_ parent: Live2DView) {
            self.parent = parent
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            parent.viewModel.updateViewSize(size)
        }
        
        func draw(in view: MTKView) {
            guard let device = view.device,
                  let commandBuffer = device.makeCommandQueue()?.makeCommandBuffer() else {
                return
            }
            
            let currentTime = CACurrentMediaTime()
            let deltaTime = lastFrameTime > 0 ? currentTime - lastFrameTime : 1.0 / 60.0
            lastFrameTime = currentTime
            
            parent.viewModel.update(deltaTime: deltaTime)
            parent.viewModel.render(in: view, commandBuffer: commandBuffer)
            
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
            
            // Update performance metrics
            PerformanceMonitor.shared.updateFPS()
            if frameCount % 60 == 0 { // Log every 60 frames
                PerformanceMonitor.shared.logPerformanceMetrics(device: device)
            }
        }
        
        private var frameCount: Int = 0
    }
}

#Preview {
    Live2DView(viewModel: try! Live2DViewModel())
        .frame(width: 300, height: 400)
}
