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
  
  var updateTimeProgressTimer: Timer!
  var isCreatingClip = false
  
  
  // MARK: - Setup
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInterface()
    startProgressTimer()
  }
  
  
  // MARK: - Interface
  
  private func setupInterface() {
    artworkImageView.image = AudioManager.shared.artwork ?? UIImage(named: "artwork")
    episodeNameLabel.text = AudioManager.shared.episodeName ?? ""
    podcastNameLabel.text = AudioManager.shared.podcastName ?? "No media selected"
    detailsLabel.text = AudioManager.shared.details ?? ""
    totalTimeLabel.text = AudioManager.shared.durationString
    clipButton.isHidden = !AudioManager.shared.trackIsEpisode
    bookmarkButton.isHidden = !AudioManager.shared.trackIsEpisode
    playPauseButton.setBackgroundImage(UIImage(named: AudioManager.shared.isPlaying ? "pause" : "play"), for: .normal)
    updateTimeProgress()
    artworkImageView.layer.cornerRadius = 4.0
    artworkImageView.clipsToBounds = true
  }
  
  private func updateTimeProgress() {
    currentTimeLabel.text = AudioManager.shared.currentTimeString
    timeSlider.value = AudioManager.shared.progress
  }
  
  private func startProgressTimer() {
    updateTimeProgressTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                                   repeats: true,
                                                   block: { (timer) in
                                                    self.updateTimeProgress()})
  }
  
  
  // MARK: - Player controls
  
  @IBAction func playPause(_ sender: UIButton) {
    if AudioManager.shared.isPlaying { pausePlayer() } else { resumePlayer() }
  }
  
  private func pausePlayer() {
    AudioManager.shared.pause()
    updateTimeProgressTimer.invalidate()
    playPauseButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
  }
  
  private func resumePlayer() {
    AudioManager.shared.resume()
    startProgressTimer()
    playPauseButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
  }
  
  @IBAction func backward(_ sender: UIButton) {
    AudioManager.shared.backward(5)
    updateTimeProgress()
  }
  
  @IBAction func forward(_ sender: UIButton) {
    AudioManager.shared.forward(5)
    updateTimeProgress()
  }
  
  @IBAction func timeSliderValueChanged(_ sender: UISlider) {
    AudioManager.shared.setProgress(timeSlider.value)
    updateTimeProgress()
  }
  
  
  // MARK: - Bookmarks
  
  @IBAction func newBookmark(_ sender: UIButton) {
    var wasPlaying = false
    if AudioManager.shared.isPlaying {
      pausePlayer()
      wasPlaying = true
    }
    let newBookmarkAlert = UIAlertController.createNewItemAlert(title: "New Bookmark", message: "\(AudioManager.shared.podcastName!)\n\(AudioManager.shared.episodeName!)\n\(AudioManager.shared.currentTimeString!)", cancelBlock: {
      if wasPlaying { self.resumePlayer() }
    }) { (comment) in
      if self.saveBookmark(episode: AudioManager.shared.track as! Episode, timestamp: AudioManager.shared.currentTime!, timestampString: AudioManager.shared.currentTimeString!, comment: comment) {
        self.showSavedBookmarkAlert()
      }
      if wasPlaying { self.resumePlayer() }
    }
    self.present(newBookmarkAlert, animated: true, completion: nil)
  }
  
  private func saveBookmark(episode: Episode, timestamp: TimeInterval, timestampString: String, comment: String) -> Bool {
    let data: [String:Any] = [R.episode:episode, R.timestamp:timestamp, R.timestampString:timestampString, R.comment:comment]
    guard DataManager.create(entity: R.Bookmark, withData: data) else {
      print("Error saving bookmark")
      return false
    }
    return true
  }
  
  private func showSavedBookmarkAlert() {
    
    let popupFrame = CGRect(x: self.view.center.x - 100, y: self.view.center.y - 50, width: 200, height: 100)
    let popup = UIView(frame: popupFrame)
    popup.backgroundColor = UIColor.darkGray
    popup.alpha = 0.98
    
    let popupLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    popupLabel.center = CGPoint(x: 100, y: 50)
    popupLabel.textColor = .white
    popupLabel.textAlignment = .center
    popupLabel.font = UIFont.boldSystemFont(ofSize: 17)
    popupLabel.text = "Bookmarked saved!"
    popup.addSubview(popupLabel)
    
    self.view.addSubview(popup)
    
    UIView.animate(withDuration: 0.5, delay: 2, options: [], animations: {
      popup.alpha = 0
    }) { (completed) in
      popup.removeFromSuperview()
    }
  }
  
  
  // MARK: - Clips
  
  @IBAction func newClip(_ sender: UIButton) {
    
  }
  
  
  // MARK: - Dismiss
  
  @IBAction func dismiss(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
    if !isCreatingClip{
      self.dismiss(animated: true, completion: nil)
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


// MARK: - AVAudioPlayerDelegate
// TODO: This
