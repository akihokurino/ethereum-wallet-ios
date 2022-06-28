import Foundation

private enum UserDefaultsKey {
    static let suiteName = "group.app.akiho.ethereum-wallet"
    static let privateKey = "private-key"
    static let tokens = "tokens"
}

struct DataStore {
    let store = UserDefaults.standard

    static let shared = DataStore()
    private init() {}

    func getPrivateKey() -> Data? {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        return userDefaults.data(forKey: UserDefaultsKey.privateKey)
    }

    func savePrivateKey(val: Data) {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        userDefaults.set(val, forKey: UserDefaultsKey.privateKey)
    }

    func getTokens() -> [[String: Any]] {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        return userDefaults.array(forKey: UserDefaultsKey.tokens) as? [[String: Any]] ?? []
    }

    func saveTokens(val: [[String: Any]]) {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        userDefaults.set(val, forKey: UserDefaultsKey.tokens)
    }
}
