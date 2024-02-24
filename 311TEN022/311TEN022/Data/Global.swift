//
//  Global.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/16/23.
//

import Foundation

class Global {
    static let shared = Global()
    
    // 현재 날짜(년, 월)
    var selectedYear: String!
    var selectedMonth: String!
    var currentYear: String!
    var currentMonth: String!
    
    private init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        self.selectedYear = formatter.string(from: Date())
        self.currentYear = formatter.string(from: Date())
        formatter.dateFormat = "M"
        self.selectedMonth = formatter.string(from: Date())
        self.currentMonth = formatter.string(from: Date())
    }
    
    static let BGColorHexCode = "#F0F0E6"
    static let PointColorHexCode = "#343C19"
    
    // success message
    static let goalRecordSuccessTitle = "목표가 저장됐어요!"
    static let boardRecordSuccessTitle = "소비기록이 저장됐어요!"
    static let boardModifySuccessTitle = "소비기록이 수정됐어요!"
    static let boardDeleteSuccessTitle = "소비기록이 삭제됐어요!"
    
    // error message
    static let goalRecordFailTitle = "목표가 저장에 실패했습니다!"
    
    static let kakaoSignInErrorTitle = "Kakao 로그인 실패"
    static let kakaoSignInErrorMessage = "Kakao 로그인에 실패했습니다"
    
    static let appleSignInErrorTitle = "Apple 로그인 실패"
    static let appleSignInErrorMessage = "Apple 로그인에 실패했습니다"
}


