//
//  UserInfo.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/2/23.
//

import Foundation

struct UserInfo {
    static let memberId: String = String(UserDefaults.standard.integer(forKey: "memberId"))
    static let email: String = UserDefaults.standard.string(forKey: "email") ?? ""
    static let name: String = UserDefaults.standard.string(forKey: "name") ?? ""
    static var token: String = String(UserDefaults.standard.string(forKey: "token") ?? "")
}
