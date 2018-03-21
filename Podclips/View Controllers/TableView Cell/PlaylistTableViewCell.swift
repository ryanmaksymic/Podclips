//
//  PlaylistTableViewCell.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-21.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

protocol PlaylistTableViewCellDelegate {

}

class PlaylistTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    var onDownloadTapped: ((UITableViewCell) -> Void)? = nil
    
    var delegate: PlaylistTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func downloadTapped(_ sender: UIButton) {
        progressLabel.isHidden = false
        onDownloadTapped?(self)
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        progressLabel.text = String(format: "%.1f %%", progress * 100)
    }
    
}
