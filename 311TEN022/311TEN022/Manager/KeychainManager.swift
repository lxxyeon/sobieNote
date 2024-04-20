//
//  KeychainManager.swift
//  311TEN022
//
//  Created by leeyeon2 on 2/7/24.
//

import UIKit

enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case invalidItemFormat
    case unknown(OSStatus)
}

class KeychainManager {
    static let service = Bundle.main.bundleIdentifier

    // MARK: - Save
    func saveItem(userIdentifier: String,
                 account: Data) -> Bool {
        
        let addQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                         kSecAttrAccount: userIdentifier,
                                         kSecValueData : account]
        
        let result: Bool = {
            let status = SecItemAdd(addQuery as CFDictionary, nil)
            if status == errSecSuccess {
                print("키체인 저장 성공")
                return true
            } else if status == errSecDuplicateItem {
                print("키체인 중복")
//                return updateItem(userIdentifier: userIdentifier,
//                                  account: account)
            }
            
            print("addItem Error : \(status.description))")
            return false
        }()
        
        return result
    }
    
    // MARK: - Update
    func updateItem(userIdentifier: String,
                    account: Data) -> Bool {
        let prevQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                              kSecAttrAccount: userIdentifier]
        let updateQuery: [CFString: Any] = [kSecValueData: (account as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any]
        
        let result: Bool = {
            let status = SecItemUpdate(prevQuery as CFDictionary, updateQuery as CFDictionary)
            if status == errSecSuccess { return true }
            
            print("updateItem Error : \(status.description)")
            return false
        }()
        
        return result
    }
    
    // MARK: - Read
    func readItem(userIdentifier: String) -> Account? {
        let getQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrAccount: userIdentifier,
                                      kSecReturnAttributes: true,
                                      kSecReturnData: true]
        var item: CFTypeRef?
        let result = SecItemCopyMatching(getQuery as CFDictionary, &item)
        
        if result == errSecSuccess {
            if let existingItem = item as? [String: Any]{
                if let userAccountData = existingItem[kSecValueData as String] as? Data,
                   let userAccount = try? JSONDecoder().decode(Account.self, from: userAccountData){
                    return userAccount
                }
            }
        }
        
        print("getItem Error : \(result.description)")
        return nil
    }
}
