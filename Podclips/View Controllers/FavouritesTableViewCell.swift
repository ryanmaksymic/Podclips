//
//  FavouritesTableViewCell.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-15.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

class FavouritesTableViewCell: UITableViewCell {
  
  @IBOutlet weak var episodeNameLabel: UILabel!
  @IBOutlet weak var podcastNameLabel: UILabel!
  @IBOutlet weak var detailsLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var shareButton: UIButton!
  
  var onButtonTouched: ((UITableViewCell) -> Void)? = nil
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  @IBAction func share(_ sender: UIButton) {
    onButtonTouched?(self)
  }
}
