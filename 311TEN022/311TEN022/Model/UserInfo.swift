//
//  UserInfo.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/2/23.
//

import Foundation

struct UserInfo {
    static var memberId: String = String(UserDefaults.standard.integer(forKey: "memberId"))
    static var email: String = UserDefaults.standard.string(forKey: "email") ?? ""
    static var name: String = UserDefaults.standard.string(forKey: "name") ?? ""
    static var token: String = String(UserDefaults.standard.string(forKey: "token") ?? "")
    
    init() {
        UserInfo.memberId = ""
        UserInfo.email = ""
        UserInfo.name = ""
        UserInfo.token = ""
    }
}

struct Account: Codable {
    var email: String
    var name: String
}
