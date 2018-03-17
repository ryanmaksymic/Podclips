//
//  MiniPlayerViewController.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-14.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class MiniPlayerViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var episodeNameLabel: UILabel!
  @IBOutlet weak var podcastNameLabel: UILabel!
  @IBOutlet weak var playPauseButton: UIButton!
  
  
  // MARK: - Setup
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateInterface()
    NotificationCenter.default.addObserver(self, selector: #selector(updateTrackInfo), name: Notification.Name(R.AudioManagerUpdated), object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    updateInterface()
  }
  
  private func updateInterface() {
    updateTrackInfo()
    artworkImageView.layer.cornerRadius = 4.0
    artworkImageView.clipsToBounds = true
  }
  
  @objc private func updateTrackInfo() {
    self.artworkImageView.image = AudioManager.shared.artwork ?? UIImage(named: "artwork")
    self.episodeNameLabel.text = AudioManager.shared.episodeName ?? ""
    self.podcastNameLabel.text = AudioManager.shared.podcastName ?? ""
    playPauseButton.setBackgroundImage(UIImage(named: AudioManager.shared.isPlaying ? "pause" : "play"), for: .normal)
    playPauseButton.isEnabled = (AudioManager.shared.track != nil)
  }
  
  
  // MARK: - Player controls
  
  @IBAction func playPause(_ sender: UIButton) {
    if AudioManager.shared.url != nil {
      if AudioManager.shared.isPlaying { pausePlayer() } else { resumePlayer() }
    }
  }
  
  private func pausePlayer() {
    AudioManager.shared.pause()
    playPauseButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
  }
  
  private func resumePlayer() {
    AudioManager.shared.resume()
    playPauseButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
  }
  
  
  // MARK: - Touches
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if AudioManager.shared.track != nil {
      performSegue(withIdentifier: "PresentPlayer", sender: nil)
    }
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
