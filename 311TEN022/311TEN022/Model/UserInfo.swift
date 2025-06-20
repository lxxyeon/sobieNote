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
    static var nickName: String = UserDefaults.standard.string(forKey: "name") ?? ""
    static var token: String = String(UserDefaults.standard.string(forKey: "token") ?? "")
    //강원도 정보
    static var schoolName: String = String(UserDefaults.standard.string(forKey: "schoolName") ?? "")
    static var age: String = String(UserDefaults.standard.string(forKey: "age") ?? "")
    static var studentName: String = String(UserDefaults.standard.string(forKey: "studentName") ?? "")
    
    init() {
        UserInfo.memberId = ""
        UserInfo.email = ""
        UserInfo.nickName = ""
        UserInfo.token = ""
        //
        UserInfo.schoolName = ""
        UserInfo.age = ""
        UserInfo.studentName = ""
    }
}

struct Account: Codable {
    var email: String
    var name: String
}
