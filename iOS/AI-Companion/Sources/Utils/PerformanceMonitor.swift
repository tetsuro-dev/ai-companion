import Foundation
import MetalKit

class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private var frameCount: Int = 0
    private var lastTime: CFTimeInterval = 0
    private var fps: Double = 0
    
    private var memoryFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .memory
        return formatter
    }()
    
    func updateFPS() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()
        
        if lastTime == 0 {
            lastTime = currentTime
        }
        
        let elapsedTime = currentTime - lastTime
        if elapsedTime >= 1.0 {
            fps = Double(frameCount) / elapsedTime
            frameCount = 0
            lastTime = currentTime
        }
    }
    
    func getCurrentFPS() -> Double {
        return fps
    }
    
    func getMemoryUsage() -> String {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return memoryFormatter.string(fromByteCount: Int64(info.resident_size))
        }
        
        return "N/A"
    }
    
    func getGPUUtilization(device: MTLDevice) -> Double {
        // Note: This is a simplified metric, actual GPU utilization
        // would require more sophisticated monitoring
        return device.currentAllocatedSize / Double(device.recommendedMaxWorkingSetSize)
    }
    
    func logPerformanceMetrics(device: MTLDevice) {
        print("=== Performance Metrics ===")
        print("FPS: \(String(format: "%.1f", fps))")
        print("Memory: \(getMemoryUsage())")
        print("GPU Usage: \(String(format: "%.1f%%", getGPUUtilization(device) * 100))")
        print("========================")
    }
}
