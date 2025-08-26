//
//  APIConfig.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import Foundation
import Alamofire

// /board/posting/{boardId}
//
struct APIConfig {
    //최최종
    static let baseURL = "https://sobienote.p-e.kr"
    
//    static let baseURL = "http://34.22.77.31:8080"
//    static let baseURL = "http://34.64.225.87:8080"
//    static let baseURL = "http://34.47.91.193:8080"
    
    static var headers: HTTPHeaders = ["Accept" : "application/json, application/javascript, text/javascript, text/json",
                                "Content-Type" : "application/json; charset=UTF-8"]
    static let authHeaders: HTTPHeaders = ["Accept" : "application/json, application/javascript, text/javascript, text/json",
                                    "Content-Type" : "application/json; charset=UTF-8",
                                           "Authorization" : "Bearer \(UserInfo.token)"]

    static let multiPartHeaders: HTTPHeaders = ["Content-Type" : "multipart/form-data"]
}
