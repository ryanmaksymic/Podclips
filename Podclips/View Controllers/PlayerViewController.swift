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
  
  @IBOutlet weak var progressSlider: ProgressSlider!
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var totalTimeLabel: UILabel!
  @IBOutlet weak var editFromTimeLabel: UILabel!
  @IBOutlet weak var editToTimeLabel: UILabel!
  @IBOutlet weak var editFromTimeStepper: UIStepper!
  @IBOutlet weak var editToTimeStepper: UIStepper!
  
  
  // TODO: Add steppers to adjust edit times by 1/10 seconds
  
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var bookmarkButton: UIButton!
  @IBOutlet weak var clipButton: UIButton!
  @IBOutlet weak var clipCancelButton: UIButton!
  @IBOutlet weak var clipSaveButton: UIButton!
  @IBOutlet weak var controlButtonsView: UIView!
  
  
  // MARK: - Properties
  
  var updateTimeProgressTimer: Timer!
  var isCreatingClip = false
  var saveAlert = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
  
  
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
  
  // TODO: While editing, play only between handles
  
  
  // MARK: - Bookmarks
  
  @IBAction func newBookmark(_ sender: UIButton) {
    var wasPlaying = false
    if AudioManager.shared.isPlaying {
      pausePlayer()
      wasPlaying = true
    }
    let newBookmarkAlert = UIAlertController.createNewItemAlert(title: "New Bookmark", message: "\(AudioManager.shared.episodeName!)\n\(AudioManager.shared.podcastName!)\n\(AudioManager.shared.currentTimeString!)", cancelBlock: {
      if wasPlaying { self.resumePlayer() }
    }) { (comment) in
      if self.saveBookmark(episode: AudioManager.shared.track as! Episode, timestamp: AudioManager.shared.currentTime!, timestampString: AudioManager.shared.currentTimeString!, comment: comment) {
        self.showSaveAlert(message: "Bookmark saved!", dismiss: true)
      } else { self.showSaveAlert(message: "Error saving bookmark") }
      if wasPlaying { self.resumePlayer() }
    }
    self.present(newBookmarkAlert, animated: true, completion: nil)
  }
  
  private func saveBookmark(episode: Episode, timestamp: TimeInterval, timestampString: String, comment: String) -> Bool {
    let data: [String:Any] = [R.episode:episode, R.timestamp:timestamp, R.timestampString:timestampString, R.comment:comment]
    guard DataManager.create(entity: R.Bookmark, withData: data) else {
      return false
    }
    return true
  }
  
  
  // MARK: - Clips
  
  @IBAction func newClip(_ sender: UIButton) {
    pausePlayer()
    toggleClipEditorInterface()
  }
  
  // TODO: Left handle jumps to knob's position
  func toggleClipEditorInterface() {
    if !isCreatingClip {
      clipCancelButton.center.x -= 200
      editFromTimeStepper.center.x -= 200
      clipSaveButton.center.x += 200
      editToTimeStepper.center.x += 200
      clipCancelButton.isHidden = false
      clipSaveButton.isHidden = false
      editFromTimeStepper.isHidden = false
      editToTimeStepper.isHidden = false
    }
    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
      self.clipCancelButton.center.x += self.isCreatingClip ? -200 : 200
      self.editFromTimeStepper.center.x += self.isCreatingClip ? -200 : 200
      self.clipSaveButton.center.x += self.isCreatingClip ? 200 : -200
      self.editToTimeStepper.center.x += self.isCreatingClip ? 200 : -200
      self.controlButtonsView.center.y += self.isCreatingClip ? -50 : 50
      self.dismissButton.isHidden = !self.isCreatingClip
      self.clipButton.alpha = self.isCreatingClip ? 1 : 0
      self.bookmarkButton.alpha = self.isCreatingClip ? 1 : 0
      self.editFromTimeLabel.alpha = self.isCreatingClip ? 0 : 1
      self.editToTimeLabel.alpha = self.isCreatingClip ? 0 : 1
    }) { (completed) in
      if !self.isCreatingClip {
        self.clipCancelButton.center.x += 200
        self.editFromTimeStepper.center.x += 200
        self.clipSaveButton.center.x -= 200
        self.editToTimeStepper.center.x -= 200
        self.clipCancelButton.isHidden = true
        self.clipSaveButton.isHidden = true
        self.editFromTimeStepper.isHidden = true
        self.editToTimeStepper.isHidden = true
      }
    }
    isCreatingClip = !isCreatingClip
    progressSlider.isInEditingMode = !progressSlider.isInEditingMode
  }
  
  @IBAction func cancelClip(_ sender: UIButton) {
    toggleClipEditorInterface()
  }
  
  @IBAction func saveClip(_ sender: UIButton) {
    let newClipAlert = UIAlertController.createNewItemAlert(title: "New Clip", message: "\(AudioManager.shared.episodeName!)\n\(AudioManager.shared.podcastName!)\nDURATION", cancelBlock: {
    }) { (comment) in
      self.saveClip(comment: comment)
    }
    self.present(newClipAlert, animated: true, completion: nil)
  }
  
  // TODO: Make this method more like saveBookmark
  private func saveClip(comment: String) {
    showSaveAlert(message: "Saving clip...")
    
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
        self.showSaveAlert(message: "Error saving clip", dismiss: true)
      case AVAssetExportSessionStatus.cancelled:
        self.showSaveAlert(message: "Error saving clip", dismiss: true)
      default:
        DispatchQueue.main.async {
          self.toggleClipEditorInterface()
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
          self.showSaveAlert(message: "Clip saved!", dismiss: true)
        }
      }
    })
    // TODO: Return success boolean to view controller
  }
  
  
  // MARK: - Alerts
  
  func showSaveAlert(message: String, dismiss: Bool = false) {
    saveAlert.title = message
    if self.presentedViewController == nil {
      present(saveAlert, animated: true, completion: nil)
    }
    if dismiss {
      Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
        self.saveAlert.dismiss(animated: true, completion: nil)
      })
    }
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
    // TODO: Do the same for MiniPlayerVC
  }
}
