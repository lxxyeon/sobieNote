//
//  Config.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import Foundation
import Alamofire

struct Config {
    static let baseURL = "http://118.67.129.168:8080"
    static let headers: HTTPHeaders = ["Accept" : "application/json, application/javascript, text/javascript, text/json",
                                "Content-Type" : "application/json; charset=UTF-8"]
    static let authHeaders: HTTPHeaders = ["Accept" : "application/json, application/javascript, text/javascript, text/json",
                                    "Content-Type" : "application/json; charset=UTF-8",
                                    "Authorization" : "Bearer \(String(describing: UserDefaults.standard.string(forKey: "token")))"]
    static let multiPartHeaders: HTTPHeaders = ["Accept" : "application/json, application/javascript, text/javascript, text/json",
                                         "Content-Type" : "multipart/form-data"]
}
