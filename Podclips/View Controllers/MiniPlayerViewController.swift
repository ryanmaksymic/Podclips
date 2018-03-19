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
    artworkImageView.layer.cornerRadius = 4.0
    artworkImageView.clipsToBounds = true
    updateTrackInfo()
    NotificationCenter.default.addObserver(self, selector: #selector(updateTrackInfo), name: Notification.Name(R.NewSongLoaded), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(clearTrackInfo), name: Notification.Name(R.SongEnded), object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if AudioManager.shared.isTrackLoaded { updateTrackInfo() }
    else { clearTrackInfo() }
  }
  
  @objc private func updateTrackInfo() {
    self.artworkImageView.image = AudioManager.shared.artwork ?? UIImage(named: "artwork")
    self.episodeNameLabel.text = AudioManager.shared.episodeName ?? ""
    self.podcastNameLabel.text = AudioManager.shared.podcastName ?? ""
    playPauseButton.setBackgroundImage(UIImage(named: AudioManager.shared.isPlaying ? "pause" : "play"), for: .normal)
    playPauseButton.isEnabled = (AudioManager.shared.track != nil)
    AudioManager.shared.delegate = self
  }
  
  @objc private func clearTrackInfo() {
    self.artworkImageView.image = UIImage(named: "artwork")
    self.episodeNameLabel.text = ""
    self.podcastNameLabel.text = ""
    playPauseButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
    playPauseButton.isEnabled = false
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
}


// MARK: - AVAudioPlayerDelegate

extension MiniPlayerViewController: AVAudioPlayerDelegate {

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    NotificationCenter.default.post(name: Notification.Name(R.SongEnded), object: nil)
    AudioManager.shared.isTrackLoaded = false
    clearTrackInfo()
  }
}
