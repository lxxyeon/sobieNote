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
    static let PointColorHexCode = "#363B1E"
}
