//
//  Board.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/19/23.
//

import Foundation

//기록 게시물 Model
struct BoardTageData {
    let contents: String
    let emotions: String
    let satisfactions: Int
    let factors: String
    let categories: String
}

struct BoardImage {
    let boardId: Int
    let imagePath: String
}
