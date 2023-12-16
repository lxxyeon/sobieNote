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
    func perform(memberId: String?,
                 request: APIRequest,
                 completion: @escaping APIClientCompletion) {
        var url = APIConfig.baseURL + request.path
        if let memberId = memberId{
            url = url + "/" + memberId
        }
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
                print("실패")
            }
        }
    }
    
    func getgoal(param: Parameters,
                 completion: @escaping (Int) -> Void) {
        let url = APIConfig.baseURL + "/goal/" + UserInfo.memberId
        AF.request(url,
                   method: .get,
                   headers: APIConfig.headers).responseString { response in
            switch response.result{
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        
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
    
    //목표전송
    func goalSave(param: Parameters,
                  completion: @escaping (Int) -> Void) {
        let url = APIConfig.baseURL + "/goal/" + UserInfo.memberId
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: APIConfig.authHeaders).responseString { response in
            switch response.result{
                //200인 경우 성공
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            
                            completion(1)
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

    //로그인
    //http://118.67.129.168:8080/member/login
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
    
//    {"satisfactions":"80", "emotions":"설레는", "contents":"내용", "categories":"여행", "factors":"효율증가"}
    func posting(param: Parameters,
                completion: @escaping (Int) -> Void) {
        let user = String(UserDefaults.standard.integer(forKey: "memberId"))
        let url = APIConfig.baseURL+"/boardV1/posting/\(user)"
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
                            let postId = jsonDict["data"] as! Int
                            completion(postId)
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
    // MARK: - 파일 업로드 API
    func fileUpload(imageData: UIImage,
                    completion: @escaping (String) -> Void) {
    //http://118.67.129.168:8080/board/posting/image/
   // http:118.67.129.168:8080/board/posting/image/1
//        let url = APIConfig.baseURL+"/board/posting/" + "image/4"
        let url = APIConfig.baseURL+"/board/posting/" + UserInfo.memberId
        let headerMultipart: HTTPHeaders = ["Accept" : "application/json, application/javascript, text/javascript, text/json",
                                                   "Content-Type" : "multipart/form-data",
                                            "Authorization" : "Bearer \(UserInfo.token))"]
//        let url = Config.baseURL+"/archive-files"
                let categorie = "식품"
                let emotion = "행복한"
                let factor = "환경보호"
                let satisfaction = 80
                let content = "좋아"
        
//                let parameters: [String : Any] = [:]
                let parameters: [String : Any] = ["contents": content,
                                                    "emotions": emotion,
                                                    "satisfactions": satisfaction,
                                                    "factors": factor,
                                                    "categories": categorie]
//        let parameters: [String : Any] = [:]
        let imageData = imageData.jpegData(compressionQuality: 1)
        
        AF.upload(multipartFormData: { MultipartFormData in
            //body 추가
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if let image = imageData {
                MultipartFormData.append(image, withName: "file", fileName: "test.jpeg", mimeType: "image/jpeg")
            }
        }, to: url, method: .post, headers: headerMultipart)
        .validate(statusCode: 200..<600)
        .responseString { response in
            switch response.result{
                //200인 경우 성공
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            //                 let postId = jsonDict["data"] as! Int
                            //                 completion(postId)
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
            default:
                print("dd")
            }}
        
//

////        let imageData = imageData.jpegData(compressionQuality: 1)
//        let MultipartHeaders: HTTPHeaders = ["Content-Type" : "multipart/form-data",
//                                             "Authorization" : "Bearer \(UserInfo.token))"]
////        if let sendImg = imageData.jpegData(compressionQuality: 0.5){
//        let imageData = imageData.jpegData(compressionQuality: 0.3)
//            let header: HTTPHeaders = MultipartHeaders
//            let param: Parameters = parameters
//            AF.upload(multipartFormData: { MultipartFormData in
//                //body 추가
//                for (key, value) in parameters {
//                    MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
//                }
//
////                for (key, value) in parameters {
////                    MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "application/json")
////                }
//                if let image = imageData {
//                    MultipartFormData.append(image, withName: "file", fileName: "test.jpeg", mimeType: "image/jpeg")
//                }
////                MultipartFormData.append(sendImg, withName: "file", fileName: "file.jpeg", mimeType: "image/jpeg")
//            }, to: url, method: .post, headers: header)
//            .validate(statusCode: 200..<300)
//            .responseData { response in
//                switch response.result {
//                case .success(let resData):
//                    print(resData)
//                case .failure(_):
//                    print("fail")
//                }}
                
//            .responseDecodable(of: GetUrl.self, completionHandler:  { response in
//                switch response.result{
//                case .success(let data):
//                    print("url : \(data.url)")
//                    completion(data.url)
//                    //url 로 저장
//                case .failure(let error):
//                    print(error)
//                }
//            })
//        }
    }
    
    
    // MARK: - 파일 업로드 API
    func fileUpload(imageData: UIImage,
                    param: Parameters,
                    completion: @escaping (String) -> Void) {
        let url = APIConfig.baseURL+"/board/posting/" + UserInfo.memberId
        let categorie = "식품"
        let emotion = "행복한"
        let factor = "환경보호"
        let satisfaction = 80
        let content = " "
//        let parameters: Parameters =
        let parametersIn: [String : Any] = ["contents": content,
                                            "emotions": emotion,
                                            "satisfactions": satisfaction,
                                 "factors": factor, "categories": categorie]
//        let parametersIn2: [String : Any] = ["attachFile": "test.jpeg"]
        let parameters: [String : Any] = ["boardRequest": parametersIn, "attachFile": "test.jpeg"]
        
        let imageData = imageData.jpegData(compressionQuality: 1)
        
        
        
        
        AF.upload(multipartFormData: { MultipartFormData in
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if let image = imageData {
                MultipartFormData.append(image, withName: "attachFile", fileName: "test.jpeg", mimeType: "image/jpeg")
            }
        }, to: url, method: .post, headers: APIConfig.multiPartHeaders)
        .validate()
        .responseDecodable(of: GetUrl.self, completionHandler:  { response in
            switch response.result{
            case .success(let data):
                print("url : \(data.url)")
                completion(data.url)
                //url 로 저장
            case .failure(let error):
                print(error)
            }
        })
    }
    
    struct GetUrl: Decodable {
        let url: String
    }
}
