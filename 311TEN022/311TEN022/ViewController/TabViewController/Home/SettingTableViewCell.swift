//
//  SettingTableViewCell.swift
//  311TEN022
//
//  Created by leeyeon2 on 2/10/24.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingImg: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
