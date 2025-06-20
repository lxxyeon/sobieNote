//
//  Extension+UIImageView.swift
//  311TEN022
//
//  Created by leeyeon2 on 3/18/25.
//

import UIKit
import Kingfisher

extension UIImageView {
    // paging 처리
    func loadImage(urlString: String) {
        ImageCache.default.retrieveImage(forKey: urlString) { result in
            switch result {
            case .success(let value):
                // 캐시 존재
                if let image = value.image {
                    self.image = image
                } else {
                    //캐시 미 존재
                    guard let url = URL(string: urlString) else { return }
                    self.kf.setImage(with: url)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
