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
    
    //Bold
    class func kimB20() -> UIFont {
        return UIFont(name: kimFontName.Bold.rawValue, size: 20)!
    }
    
    class func kimB19() -> UIFont {
        return UIFont(name: kimFontName.Bold.rawValue, size: 19)!
    }
    
    class func kimB18() -> UIFont {
        return UIFont(name: kimFontName.Bold.rawValue, size: 18)!
    }
    
    class func kimB16() -> UIFont {
        return UIFont(name: kimFontName.Bold.rawValue, size: 16)!
    }
    
    //Regular
    class func kimR18() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 18)!
    }
    
    class func kimR17() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 17)!
    }
    
    class func kimR16() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 16)!
    }
    
    class func kimR15() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 15)!
    }
    
    class func kimR14() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 14)!
    }
    
    class func kimR13() -> UIFont {
        return UIFont(name: kimFontName.Regular.rawValue, size: 13)!
    }
}

/// 로그인 호출 방식
public enum LaunchMethod: String {
    
    /// 커스텀 스킴
    case CustomScheme = "uri_scheme"
    
    /// 유니버셜 링크
    case UniversalLink = "universal_link"
}
