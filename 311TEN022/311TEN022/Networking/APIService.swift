//
//  APIService.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import Foundation
import Alamofire
import UIKit

final class APIService {
    static let shared = APIService()
    typealias APIClientCompletion = (APIResult<Data?>) -> Void
    
    // MARK: - perform
    func perform(request: APIRequest,
                 completion: @escaping APIClientCompletion) {
        let url = APIConfig.baseURL + request.path
        
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        AF.request(url,
                   method: request.method,
                   parameters: request.param,
                   encoding: JSONEncoding.default,
                   headers: request.headers)
        .validate(statusCode: 200..<400)
        .responseString { response in
            switch response.result{
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            completion(.success(APIResponse<Data?>(statusCode: response.response?.statusCode ?? 400,
                                                                   body: jsonDict)))
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
            default:
                print(response.result)
                completion(.failure(.requestFailed))
            }
        }
    }
    
    // MARK: - 파일 업로드 API (저장, 삭제)
    func fileUpload(imageData: UIImage,
                    method: HTTPMethod,
                    path: String,
                    parameters: [String : Any],
                    completion: @escaping (String?) -> Void) {
        let url = APIConfig.baseURL+"/board/posting/" + path
        let headerMultipart: HTTPHeaders = ["Accept" : "application/json, application/javascript, text/javascript, text/json",
                                            "Content-Type" : "multipart/form-data",
                                            "Authorization" : "Bearer \(UserInfo.token))"]
        let imageData = imageData.jpegData(compressionQuality: 1)
        AF.upload(multipartFormData: { MultipartFormData in
            //body 추가
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if let image = imageData {
                MultipartFormData.append(image, withName: "file", fileName: "test.jpeg", mimeType: "image/jpeg")
            }
        }, to: url, method: method, headers: headerMultipart)
        .validate(statusCode: 200..<600)
        .responseString { response in
            switch response.result{
                //200인 경우 성공
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            if let error = jsonDict["error"] {
                                completion(nil)
                            }else{
                                completion("postnumber")
                            }
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
            default:
                print("업로드 실패")
            }}
    }
    
    // 소셜로그인 API
    func signInSocial(param: Parameters,
                      type: String,
                      completion: @escaping (Any?) -> Void) {
        
        let url = APIConfig.baseURL+"/member/social"
        
        // type 추가
        var newParam: Parameters = param
        newParam["type"] = type
        
        AF.request(url,
                   method: .post,
                   parameters: newParam,
                   encoding: JSONEncoding.default,
                   headers: APIConfig.headers).responseString { response in
            switch response.result{
                //200인 경우 성공
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            if let error = jsonDict["error"] {
                                completion(nil)
                            }else{
                                let dataDict = jsonDict["data"] as! Dictionary<String,Any>
                                
                                let accessToken = dataDict["accessToken"] as! String
                                let memberId = "\(dataDict["memberId"] as! Int)"
                                
                                UserDefaults.standard.setValue(accessToken, forKey: "token")
                                UserInfo.token = accessToken
                                UserDefaults.standard.setValue(memberId, forKey: "memberId")
                                UserInfo.memberId = memberId
                                completion(dataDict)
                            }
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
            default:
                completion(nil)
            }
        }
    }
    
    // 자체 로그인
    func signIn(param: Parameters,
                completion: @escaping (Any?) -> Void) {
        let url = APIConfig.baseURL+"/member/login"
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: APIConfig.headers).responseString { response in
            switch response.result{
                //200인 경우 성공
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            if let error = jsonDict["error"] {
                                completion(nil)
                            }else{
                                let dataDict = jsonDict["data"] as! Dictionary<String,Any>
                                UserInfo.memberId = "\(dataDict["memberId"] as! Int)"
                                UserInfo.token = dataDict["accessToken"] as! String
                                UserDefaults.standard.set(Int(UserInfo.memberId) ?? 0, forKey: "memberId")
                                UserDefaults.standard.set(UserInfo.token, forKey: "token")
                                completion(dataDict)
                            }
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
            default:
                completion(nil)
            }
        }
    }
}
