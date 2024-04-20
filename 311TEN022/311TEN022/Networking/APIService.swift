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
        .validate(statusCode: 200..<300)
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
            }
        }
    }
    
    // MARK: - 파일 업로드 API (저장, 삭제)
    func fileUpload(imageData: UIImage,
                    method: HTTPMethod,
                    path: String,
                    parameters: [String : Any],
                    completion: @escaping (String) -> Void) {
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
                            completion("test")
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
            default:
                print("업로드 실패")
            }}
    }
    
    //로그인
    func signIn(param: Parameters,
                completion: @escaping (Int) -> Void) {
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
                            let userId = jsonDict["memberId"] as! Int
                            let accessToken = jsonDict["accessToken"] as! String
                            UserDefaults.standard.setValue(accessToken, forKey: "token")
                            UserInfo.token = accessToken
                            completion(userId)
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
            default:
                completion(0)
            }
        }
    }
}
