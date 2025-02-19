import Foundation

struct Live2DModel {
    let modelName: String
    let expressions: [String: Float]
    var currentExpression: String
    
    static func load(name: String) throws -> Live2DModel {
        guard let modelPath = Bundle.main.path(forResource: name, ofType: "model3") else {
            throw Live2DError.modelLoadFailed
        }
        
        // For MVP, we'll use basic expressions
        let expressions = [
            "neutral": 0.0,
            "happy": 1.0,
            "sad": 1.0,
            "angry": 1.0,
            "surprised": 1.0
        ]
        
        return Live2DModel(
            modelName: name,
            expressions: expressions,
            currentExpression: "neutral"
        )
    }
}
