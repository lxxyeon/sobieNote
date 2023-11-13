//
//  Report.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/11/23.
//

import Foundation
struct Report {
    let boardRequest: BoardRequest

    struct BoardRequest: Codable{
        let contents: String
        let emotions: String
        let satisfactions: Int
        let factors: String
        let categories: String
    }
}
