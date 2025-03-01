//
//  Contants.swift
//  311TEN022
//
//  Created by leeyeon2 on 3/1/25.
//

import Foundation
import UIKit

// 폰트
extension UIFont {
    enum kimFontName: String {
        case Bold = "KimjungchulMyungjo-bold"
        case Regular = "KimjungchulMyungjo-Regular"
    }
    
    class func kimR20() -> UIFont {
        return UIFont(name: kimFontName.Bold.rawValue, size: 20)!
    }
    
    class func kimR19() -> UIFont {
        return UIFont(name: kimFontName.Bold.rawValue, size: 19)!
    }
    
    class func kimR18() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 18)!
    }
    
    class func kimR17() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 17)!
    }
    
    class func kimR16() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 16)!
    }
}

/// 로그인 호출 방식
public enum LaunchMethod: String {
    
    /// 커스텀 스킴
    case CustomScheme = "uri_scheme"
    
    /// 유니버셜 링크
    case UniversalLink = "universal_link"
}
