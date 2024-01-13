//
//  TagCell.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/26/23.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    static let identifier = "TagCell"
    
    // MARK: - View
    let tagLabel: UILabel = {
        let customUILabel = UILabel()
        customUILabel.font = .systemFont(ofSize: 16)
        customUILabel.textColor = .lightGray
        customUILabel.isUserInteractionEnabled = false
        customUILabel.translatesAutoresizingMaskIntoConstraints = false
        return customUILabel
    }()
    
    override var isSelected: Bool {
      didSet {
        if isSelected {
            backgroundColor = UIColor(hexCode: Global.PointColorHexCode)
            tagLabel.textColor = UIColor(hexCode: "FCFDFC")
        } else {
            backgroundColor = .white
            tagLabel.textColor = .lightGray
        }
      }
    }
    
    // MARK: - layout
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
        addSubview(tagLabel)
        setConstraint()
    }
    
    func setConstraint() {
        NSLayoutConstraint.activate([
            tagLabel.centerXAnchor.constraint(equalTo:
                                                self.centerXAnchor),
            tagLabel.centerYAnchor.constraint(equalTo:
                                                self.centerYAnchor)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
