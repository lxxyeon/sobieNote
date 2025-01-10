//
//  Report.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/11/23.
//

import Foundation

//기록 Model
struct Report: Codable {
    let boardRequest: BoardRequest

    struct BoardRequest: Codable{
        let contents: String
        let emotions: String
        let satisfactions: Int
        let factors: String
        let categories: String
    }
}

struct ReportImage {
    let boardId: Int
    let imagePath: String
}

struct ReportData {
    let keyword: String
//    let value: Int
    var value: Int
}
