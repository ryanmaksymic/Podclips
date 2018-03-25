//
//  EpisodeTableViewCell.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-20.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {
    
    var onButtonTapped: ((UITableViewCell) -> Void)? = nil

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    
    @IBAction func downloadTapped(_ sender: UIButton) {
        onButtonTapped?(self)
        //addToPlaylistButton.setTitle("Added to Playlist", for: .normal)
        //addToPlaylistButton.setBackgroundImage(nil, for: .normal)
    }
}
