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
    
    
    // MARK: - 파일 업로드 API
    func fileUpload(imageData: UIImage,
                    completion: @escaping (String) -> Void) {
        let url = baseURL+"/archive-files"
        
        let parameters: [String : Any] = [:]
        let imageData = imageData.jpegData(compressionQuality: 1)
        
        AF.upload(multipartFormData: { MultipartFormData in
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if let image = imageData {
                MultipartFormData.append(image, withName: "file", fileName: "test.jpeg", mimeType: "image/jpeg")
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
