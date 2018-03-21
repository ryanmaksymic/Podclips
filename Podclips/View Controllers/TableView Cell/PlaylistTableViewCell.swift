//
//  PlaylistTableViewCell.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-21.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var onDownloadTapped: ((UITableViewCell) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func downloadTapped(_ sender: UIButton) {
        onDownloadTapped?(self)
    }
    
}
