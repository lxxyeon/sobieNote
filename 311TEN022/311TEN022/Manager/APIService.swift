//
//  APIService.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import Foundation
import Alamofire
import UIKit

struct Config {
    static let baseURL = "http://118.67.129.168:8080"
    static let headers: HTTPHeaders = ["Content-Type" : "application/json"]
}


final class APIService {
    static let shared = APIService()
    var headers: HTTPHeaders = Config.headers
    let memberId = String(UserDefaults.standard.integer(forKey: "memberId"))
    
    //MARK: - Goal
    func getgoal(param: Parameters,
                 completion: @escaping (Int) -> Void) {
        let url = Config.baseURL+"/goal/\(memberId)"
        AF.request(url,
                   method: .get,
                   headers: headers).responseString { response in
            switch response.result{
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            let userId = jsonDict["mission"] as! Int
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
    
    func goalSave(param: Parameters,
                  completion: @escaping (Int) -> Void) {
        
        let url = Config.baseURL+"/goal/\(memberId)"
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: headers).responseString { response in
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
        let url = Config.baseURL+"/member/login"
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: headers).responseString { response in
            switch response.result{
                //200인 경우 성공
            case .success(_):
                do{
                    let dataString = String(data: response.data!, encoding: .utf8)
                    if let jsonData = dataString!.data(using: .utf8) {
                        if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            let userId = jsonDict["memberId"] as! Int
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
        let url = Config.baseURL+"/boardV1/posting/\(user)"
        AF.request(url,
                   method: .post,
                   parameters: param,
                   encoding: JSONEncoding.default,
                   headers: headers).responseString { response in
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
                    param: Parameters,
                    completion: @escaping (String) -> Void) {
        let url = baseURL+"/board/posting/\(memberId)"
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
        }, to: url, method: .post, headers: headerMultipart)
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
