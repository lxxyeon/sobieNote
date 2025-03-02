//
//  Extension+UIView.swift
//  311TEN022
//
//  Created by leeyeon2 on 3/2/25.
//
import UIKit

extension UIView {
    // UIView to UIImage
    func transfromToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
