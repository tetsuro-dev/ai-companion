import Foundation

struct Live2DModel {
    let modelName: String
    let expressions: [String: Float]
    var currentExpression: String
    
    static func load(name: String) throws -> Live2DModel {
        guard let modelPath = Bundle.main.path(forResource: name, ofType: "model3", inDirectory: "Live2D/\(name)") else {
            throw Live2DError.modelLoadFailed
        }
        
        // For MVP, we'll use basic expressions mapped to motion files
        let expressions = [
            "neutral": 0.0,  // mark_m01.motion3.json
            "idle": 1.0,     // mark_m02.motion3.json
            "speaking": 1.0,  // mark_m03.motion3.json
            "happy": 1.0,     // mark_m04.motion3.json
            "sad": 1.0,      // mark_m05.motion3.json
            "surprised": 1.0  // mark_m06.motion3.json
        ]
        
        return Live2DModel(
            modelName: name,
            expressions: expressions,
            currentExpression: "neutral"
        )
    }
    
    func getMotionFile(for expression: String) -> String? {
        let motionMap = [
            "neutral": "mark_m01",
            "idle": "mark_m02",
            "speaking": "mark_m03",
            "happy": "mark_m04",
            "sad": "mark_m05",
            "surprised": "mark_m06"
        ]
        
        guard let motionBase = motionMap[expression] else { return nil }
        return "\(motionBase).motion3.json"
    }
}
