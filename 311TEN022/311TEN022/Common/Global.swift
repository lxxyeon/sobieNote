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
    
    //color
    static let PointColorHexCode = "#21897e"

    // success message
    static let goalRecordSuccessTitle = "목표가 저장됐어요! 👍🏻"
    static let boardRecordSuccessTitle = "소비기록이 저장됐어요! 👍🏻"
    static let boardRecordFailTitle = "소비기록이 실패했어요!"
    static let boardModifySuccessTitle = "소비기록이 수정됐어요! 👍🏻"
    static let boardDeleteSuccessTitle = "소비기록이 삭제됐어요!"
    
    // error message
    static let goalRecordFailTitle = "목표가 저장에 실패했습니다!"
    
    static let kakaoSignInErrorTitle = "Kakao 로그인 실패"
    static let kakaoSignInErrorMessage = "Kakao 로그인에 실패했습니다"
    
    static let appleSignInErrorTitle = "Apple 로그인 실패"
    static let appleSignInErrorMessage = "Apple 로그인에 실패했습니다"
    
    // placeholder message
    static let recordTextViewPlaceHolder = "이 물건만의 매력 포인트나 구매 동기 등을 적어보세요!"
}

struct Tags{
    // report graph title
    static let TagTitleList = ["이번 달엔 여기에 많이 썼어요",
                               "소비하면서 느낀 감정이에요",
                               "이런 물건에 관심이 많았어요",
                               "소비 목표를 이만큼 달성했어요"]
    

    //구매카테고리 - categories 총 19개
    static let TagList1 = ["학용품","오락","대중교통","식품","도서",
                           "옷","신발","미용","화장품","액세사리",
                           "건강","취미","생활용품","전자제품",
                           "반려동물","스포츠","여행","업사이클제품"]

    //구매감정 - emotions
    static let TagList2 = ["행복한","설레는","뿌듯한","고마운","편안한","신기한","후회하는","아쉬운","불편한","걱정스러운","화나는","당황스러운"]
    //구매요인 - factors
    static let TagList3 = ["환경보호","자기계발","나눔","습관개선","호기심충족","취향디깅","효율증가","몸건강","단순구매","기분전환","소속감"]
    //구매만족도 - satisfactions
    static let TagList4 = ["100","80","60","40","20"]
}


