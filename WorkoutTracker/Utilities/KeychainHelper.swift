import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()

    func save(_ data: Data, service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // First, delete any existing item
        let deleteStatus = SecItemDelete(query as CFDictionary)
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            print("🔴 Keychain delete error: \(deleteStatus)")
        }
        
        // Then add the new item
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        if addStatus == errSecSuccess {
            print("✅ Successfully saved to Keychain: \(service)/\(account)")
            return true
        } else {
            print("🔴 Keychain save error: \(addStatus)")
            return false
        }
    }

    func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess {
            print("✅ Successfully read from Keychain: \(service)/\(account)")
            return dataTypeRef as? Data
        } else {
            print("🔴 Keychain read error: \(status)")
            return nil
        }
    }
    
    func delete(service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("✅ Successfully deleted from Keychain: \(service)/\(account)")
            return true
        } else {
            print("🔴 Keychain delete error: \(status)")
            return false
        }
    }
}
