//
//  Extension+UIImage.swift
//  311TEN022
//
//  Created by leeyeon2 on 3/2/25.
//

import UIKit

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image.withRenderingMode(renderingMode)
    }
}

