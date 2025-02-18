import Foundation

struct Character {
    let id: UUID
    var name: String
    var type: CharacterType
    
    enum CharacterType {
        case cat
        case dog
        case bird
        // Add more character types as needed
    }
    
    init(id: UUID = UUID(), name: String, type: CharacterType) {
        self.id = id
        self.name = name
        self.type = type
    }
}
