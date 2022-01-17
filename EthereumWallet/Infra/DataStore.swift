import Foundation

private enum UserDefaultsKey {
    static let suiteName = "group.app.akiho.ethereum-wallet"
    static let privateKey = "private-key"
}

struct DataStoreManager {
    let store = UserDefaults.standard

    static let shared = DataStoreManager()
    private init() {}


    func getPrivateKey() -> String {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        return userDefaults.string(forKey: UserDefaultsKey.privateKey) ?? ""
    }

    func savePrivateKey(key: String) {
        let userDefaults = UserDefaults(suiteName: UserDefaultsKey.suiteName)!
        userDefaults.set(key, forKey: UserDefaultsKey.privateKey)
    }
}
