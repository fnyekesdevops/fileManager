import Foundation

enum UserDefaultsError: Error {
    case elementMissing
}

extension UserDefaultsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .elementMissing:
            return "The element is missing"
        }
    }
}

struct UserDefaultsManager {
    private let presentationModeKey = "presentationMode"
    
    static var shared = UserDefaultsManager()
    
    var presentationMode: PresentationMode {
        get {
            guard let userDefaultsString = UserDefaults.standard.string(forKey: presentationModeKey),
                  let selectedMode = PresentationMode(rawValue: userDefaultsString) else {
                return .tableView
            }
            
            return selectedMode
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: presentationModeKey)
        }
    }
    
    private init() { }
    
    func getSelectedMode() throws -> PresentationMode? {
        throw UserDefaultsError.elementMissing
    }
}
