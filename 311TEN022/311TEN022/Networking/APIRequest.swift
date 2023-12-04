//
//  APIRequest.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/3/23.
//

import Foundation
import Alamofire

// MARK: APIRequest
struct APIRequest {
    let method: HTTPMethod
    var path: String = ""
    var queryItems: [String: Any]?
    var headers: HTTPHeaders?
    var param: Parameters?
    
    init(method: HTTPMethod) {
        self.method = method
    }

    init(method: HTTPMethod, path: String, queryItems: [String: Any]) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
    }
    
    init(method: HTTPMethod, path: String, param: Parameters, headers: HTTPHeaders){
        self.headers = headers
        self.method = method
        self.path = path
        self.param = param
    }
}
