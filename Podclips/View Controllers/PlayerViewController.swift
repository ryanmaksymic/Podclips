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
  
  @IBOutlet weak var dismissButton: UIButton!
  
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var episodeNameLabel: UILabel!
  @IBOutlet weak var podcastNameLabel: UILabel!
  @IBOutlet weak var detailsLabel: UILabel!
  
  @IBOutlet weak var progressSlider: ProgressSlider!
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var totalTimeLabel: UILabel!
  @IBOutlet weak var editFromTimeLabel: UILabel!
  @IBOutlet weak var editToTimeLabel: UILabel!
  
  // TODO: Add steppers to adjust edit times by 1/10 seconds
  
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var bookmarkButton: UIButton!
  @IBOutlet weak var clipButton: UIButton!
  @IBOutlet weak var clipCancelButton: UIButton!
  @IBOutlet weak var clipSaveButton: UIButton!
  
  
  // MARK: - Properties
  
  var updateTimeProgressTimer: Timer!
  var isCreatingClip = false
  
  
  // MARK: - Setup
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInterface()
    startProgressTimer()
    
    AudioManager.shared.delegate = self
  }
  
  
  // MARK: - Interface
  
  private func setupInterface() {
    artworkImageView.image = AudioManager.shared.artwork ?? UIImage(named: "artwork")
    episodeNameLabel.text = AudioManager.shared.episodeName ?? ""
    podcastNameLabel.text = AudioManager.shared.podcastName ?? "No media selected"
    detailsLabel.text = AudioManager.shared.details ?? ""
    totalTimeLabel.text = AudioManager.shared.durationString
    clipButton.isHidden = AudioManager.shared.trackIsClip
    bookmarkButton.isHidden = AudioManager.shared.trackIsClip
    playPauseButton.setBackgroundImage(UIImage(named: AudioManager.shared.isPlaying ? "pause" : "play"), for: .normal)
    updateTimeProgress()
    artworkImageView.layer.cornerRadius = 4.0
    artworkImageView.clipsToBounds = true
  }
  
  private func updateTimeProgress() {
    currentTimeLabel.text = AudioManager.shared.currentTimeString
    progressSlider.progress = AudioManager.shared.progress
  }
  
  private func startProgressTimer() {
    updateTimeProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.1,
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
  
  @IBAction func progressSliderValueChanged(sender: ProgressSlider) {
    AudioManager.shared.setProgress(progressSlider.progress)
    updateTimeProgress()
    
    let fromTime = TimeInterval(AudioManager.shared.duration! * Double(progressSlider.editFrom))
    editFromTimeLabel.text = fromTime.string(ms: true)
    let toTime = TimeInterval(AudioManager.shared.duration! * Double(progressSlider.editTo))
    editToTimeLabel.text = toTime.string(ms: true)
  }
  
  // TODO: Action for when progressSlider's edit handles are moved; update edit time labels
  
  
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
    pausePlayer()
    updateClipEditorInterface()
  }
  
  // TODO: Zoom in on progress slider (?)
  // TODO: Left handle jumps to knob's position
  func updateClipEditorInterface() {
    if !isCreatingClip {
      clipCancelButton.center.y += 100
      clipSaveButton.center.y += 100
      clipCancelButton.isHidden = false
      clipSaveButton.isHidden = false
      editFromTimeLabel.isHidden = false
      editToTimeLabel.isHidden = false
    }
    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
      self.clipCancelButton.center.y += self.isCreatingClip ? 100 : -100
      self.clipSaveButton.center.y += self.isCreatingClip ? 100 : -100
      self.dismissButton.isHidden = !self.isCreatingClip
      self.bookmarkButton.isEnabled = self.isCreatingClip
      self.editFromTimeLabel.isHidden = self.isCreatingClip
      self.editToTimeLabel.isHidden = self.isCreatingClip
    }) { (completed) in
      if !self.isCreatingClip {
        self.clipCancelButton.center.y -= 100
        self.clipSaveButton.center.y -= 100
        self.clipCancelButton.isHidden = true
        self.clipSaveButton.isHidden = true
      }
    }
    isCreatingClip = !isCreatingClip
    progressSlider.isInEditingMode = !progressSlider.isInEditingMode
  }
  
  @IBAction func cancelClip(_ sender: UIButton) {
  }
  
  @IBAction func saveClip(_ sender: UIButton) {
    let newClipAlert = UIAlertController.createNewItemAlert(title: "New Clip", message: "\(AudioManager.shared.podcastName!)\n\(AudioManager.shared.episodeName!)\nDURATION", cancelBlock: {
    }) { (comment) in
      self.saveClip(comment: comment)
      self.dismiss(animated: true, completion: nil)
      // TODO: Show saved clip alert if successful
    }
    self.present(newClipAlert, animated: true, completion: nil)
  }
  
  // TODO: Make this more like saveBookmark
  private func saveClip(comment: String) {
    let fromTime = AudioManager.shared.duration! * Double(progressSlider.editFrom)
    let toTime = AudioManager.shared.duration! * Double(progressSlider.editTo)
    
    let asset = AVAsset(url: AudioManager.shared.url!)
    
    // Generate unique file name:
    var fileName = AudioManager.shared.podcastName!.replacingOccurrences(of: " ", with: "")
    let uuid = UUID().uuidString
    fileName.append("-clip-\(uuid).m4a")
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
    let filemanager = FileManager.default
    if filemanager.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
      print("Error: Clip already exists!")
    }
    
    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
    exporter.outputFileType = AVFileType.m4a
    exporter.outputURL = trimmedSoundFileURL
    // Times expressed in seconds/10 for precision:
    let startTime = CMTimeMake(Int64(fromTime*10), 10)
    let stopTime = CMTimeMake(Int64(toTime*10), 10)
    let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
    exporter.timeRange = exportTimeRange
    
    exporter.exportAsynchronously(completionHandler: {
      switch exporter.status {
      case  AVAssetExportSessionStatus.failed:
        print("Error: Export failed!")
      case AVAssetExportSessionStatus.cancelled:
        print("Error: Export cancelled!")
      default:
        print("Export complete!")
        DispatchQueue.main.async {
          // TODO: Try to deal with this episode/bookmark distinction more elegantly
          let episode: Episode!
          if let bookmark = AudioManager.shared.track as? Bookmark {
            episode = bookmark.episode
          } else {
            episode = AudioManager.shared.track as? Episode
          }
          let data: [String:Any] = [R.episode:episode, R.comment:comment, R.durationString:TimeInterval(toTime - fromTime).string(), R.url:trimmedSoundFileURL]
          guard DataManager.create(entity: R.Clip, withData: data) else {
            print("Error: Clip could not be saved!")
            return
          }
          print("Clip saved!")
        }
      }
    })
    // TODO: Return success boolean to view controller
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
}


// MARK: - AVAudioPlayerDelegate

extension PlayerViewController: AVAudioPlayerDelegate {
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    playPauseButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
  }
}
