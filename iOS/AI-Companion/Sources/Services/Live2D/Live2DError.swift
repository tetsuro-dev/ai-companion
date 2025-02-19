import Foundation

enum Live2DError: Error {
    case modelLoadFailed
    case rendererInitializationFailed
    case textureLoadFailed
    case invalidExpression
    case invalidMotion
}
