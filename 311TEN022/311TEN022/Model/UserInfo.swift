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
    
    //강원도 정보(필드 총 7개)
    static var schoolName: String = String(UserDefaults.standard.string(forKey: "schoolName") ?? "")
    static var age: String = String(UserDefaults.standard.string(forKey: "age") ?? "")
    static var studentName: String = String(UserDefaults.standard.string(forKey: "studentName") ?? "")
    
    init() {
        UserInfo.memberId = ""
        UserInfo.email = ""
        UserInfo.nickName = ""
        UserInfo.token = ""
        // optional 변수
        UserInfo.schoolName = ""
        UserInfo.age = ""
        UserInfo.studentName = ""
    }
    
    // MARK: - 저장 메소드
    static func saveUserInfo(type: Int) {
        if type == 1 {
            // 강원도의 경우
            UserDefaults.standard.set(Int(memberId) ?? 0, forKey: "memberId")
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(nickName, forKey: "name")
            UserDefaults.standard.set(token, forKey: "token")
            UserDefaults.standard.set(schoolName, forKey: "schoolName")
            UserDefaults.standard.set(age, forKey: "age")
            UserDefaults.standard.set(studentName, forKey: "studentName")
            
        }else{
            UserDefaults.standard.set(Int(memberId) ?? 0, forKey: "memberId")
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(nickName, forKey: "name")
            UserDefaults.standard.set(token, forKey: "token")

        }

        UserDefaults.standard.synchronize()
        print("✅ UserInfo 저장 완료")
    }
    
    // MARK: - 출력 메소드
    static func printUserInfo() {
        print("==================== UserInfo ====================")
        print("📱 Member ID: \(memberId)")
        print("📧 Email: \(email)")
        print("👤 Nickname: \(nickName)")
        print("🔑 Token: \(token.isEmpty ? "없음" : "설정됨")")
        print("🏫 School Name: \(schoolName)")
        print("📅 Age: \(age)")
        print("👨‍🎓 Student Name: \(studentName)")
        print("==================================================")
    }
    
    // MARK: - 개별 필드 업데이트와 저장을 동시에 하는 메소드들
    static func updateMemberId(_ id: String) {
        memberId = id
        UserDefaults.standard.set(Int(id) ?? 0, forKey: "memberId")
        UserDefaults.standard.synchronize()
    }
    
    static func updateEmail(_ newEmail: String) {
        email = newEmail
        UserDefaults.standard.set(newEmail, forKey: "email")
        UserDefaults.standard.synchronize()
    }
    
    static func updateNickName(_ newNickName: String) {
        nickName = newNickName
        UserDefaults.standard.set(newNickName, forKey: "name")
        UserDefaults.standard.synchronize()
    }
    
    static func updateToken(_ newToken: String) {
        token = newToken
        UserDefaults.standard.set(newToken, forKey: "token")
        UserDefaults.standard.synchronize()
    }
    
    static func updateSchoolInfo(schoolName: String, age: String, studentName: String) {
        self.schoolName = schoolName
        self.age = age
        self.studentName = studentName
        
        UserDefaults.standard.set(schoolName, forKey: "schoolName")
        UserDefaults.standard.set(age, forKey: "age")
        UserDefaults.standard.set(studentName, forKey: "studentName")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - 모든 데이터 삭제 메소드
    static func clearUserInfo() {
        memberId = ""
        email = ""
        nickName = ""
        token = ""
        schoolName = ""
        age = ""
        studentName = ""
        
        UserDefaults.standard.removeObject(forKey: "memberId")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "schoolName")
        UserDefaults.standard.removeObject(forKey: "age")
        UserDefaults.standard.removeObject(forKey: "studentName")
        
        UserDefaults.standard.synchronize()
        print("🗑️ UserInfo 데이터 삭제 완료")
    }
}

struct Account: Codable {
    var email: String
    var name: String
}
