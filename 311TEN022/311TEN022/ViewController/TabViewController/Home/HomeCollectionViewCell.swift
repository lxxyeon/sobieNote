//
//  HomeCollectionViewCell.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import Kingfisher

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//
//  HomeCollectionViewCell.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

//import UIKit
//import Kingfisher
//
//class HomeCollectionViewCell: UICollectionViewCell {
//    
//    // MARK: - Constants
//    static let identifier = "SearchCell"
//    
//    @IBOutlet weak var cellImage: UIImageView! = {
//        let imageView = UIImageView(frame: .zero)
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFill
//        
//        return imageView
//    }()
//    
//    // MARK: - Properties
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Methods
//    private func setupUI() {
//        contentView.addSubview(cellImage)
//        
//        NSLayoutConstraint.activate([
//            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor),
//            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//    }
//    
//    public func configure(_ model: BoardImage) {
//        cellImage.loadImage(urlString: model.imagePath)
//    }
//}
