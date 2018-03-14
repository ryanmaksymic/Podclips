//
//  PlayerViewController.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-14.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class PlayerViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var episodeNameLabel: UILabel!
  @IBOutlet weak var podcastNameLabel: UILabel!
  @IBOutlet weak var detailsLabel: UILabel!
  @IBOutlet weak var timeSlider: UISlider!
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var totalTimeLabel: UILabel!
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var clipButton: UIButton!
  @IBOutlet weak var bookmarkButton: UIButton!
  
  
  // MARK: - Properties
  
  //var track: NSManagedObject?
  //var trackURL: URL?
  var updateTimeProgressTimer: Timer!
  var bookmark: Bookmark?
  
  
  // MARK: - Setup
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInterface()
  }
  
  private func setupInterface() {
    artworkImageView.image = AudioManager.shared.artwork ?? UIImage(named: "artwork")
    episodeNameLabel.text = AudioManager.shared.episodeName ?? ""
    podcastNameLabel.text = AudioManager.shared.podcastName ?? "No media selected"
    detailsLabel.text = AudioManager.shared.details ?? ""
    totalTimeLabel.text = AudioManager.shared.durationString
    clipButton.isHidden = !AudioManager.shared.trackIsEpisode
    bookmarkButton.isHidden = !AudioManager.shared.trackIsEpisode
    artworkImageView.layer.cornerRadius = 4.0
    artworkImageView.clipsToBounds = true
  }
  
  
  // MARK: - Actions
  
  @IBAction func dismiss(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  // MARK: - Gestures
  
  @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
}
