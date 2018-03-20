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
  
  @IBOutlet weak var controlButtonsView: UIView!
  @IBOutlet weak var backwardButton: UIButton!
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var forwardButton: UIButton!
  @IBOutlet weak var clipButton: UIButton!
  @IBOutlet weak var bookmarkButton: UIButton!
  @IBOutlet weak var shareButton: UIButton!
  
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var totalTimeLabel: UILabel!
  @IBOutlet weak var editFromTimeLabel: UILabel!
  @IBOutlet weak var editToTimeLabel: UILabel!
  @IBOutlet weak var editFromTimeStepper: UIStepper!
  @IBOutlet weak var editToTimeStepper: UIStepper!
  @IBOutlet weak var clipCancelButton: UIButton!
  @IBOutlet weak var clipSaveButton: UIButton!
  
  
  // MARK: - Properties
  
  var updateTimeProgressTimer: Timer!
  var isCreatingClip = false
  var saveAlert = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
  
  
  // MARK: - Setup
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInterface()
    startProgressTimer()
    NotificationCenter.default.addObserver(self, selector: #selector(dismiss(_:)), name: Notification.Name(R.SongEnded), object: nil)
  }
  
  
  // MARK: - Interface
  
  @objc private func setupInterface() {
    artworkImageView.image = AudioManager.shared.artwork ?? UIImage(named: "artwork")
    episodeNameLabel.text = AudioManager.shared.episodeName ?? ""
    podcastNameLabel.text = AudioManager.shared.podcastName ?? ""
    totalTimeLabel.text = AudioManager.shared.durationString ?? ""  // TODO: CBB episode shows shorter than actual duration time??? Figure this out.
    
    clipButton.isHidden = AudioManager.shared.trackIsClip
    bookmarkButton.isHidden = AudioManager.shared.trackIsClip
    shareButton.isHidden = !AudioManager.shared.trackIsClip
    playPauseButton.setBackgroundImage(UIImage(named: AudioManager.shared.isPlaying ? "pause" : "play"), for: .normal)
    
    dismissButton.tintColor = UIColor.init(named: Colors.secondary)
    backwardButton.tintColor = UIColor.init(named: Colors.secondary)
    playPauseButton.tintColor = UIColor.init(named: Colors.secondary)
    forwardButton.tintColor = UIColor.init(named: Colors.secondary)
    
    artworkImageView.layer.cornerRadius = 8.0
    artworkImageView.clipsToBounds = true
    
    updateTimeProgress()
  }
  
  private func startProgressTimer() {
    updateTimeProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.05,
                                                   repeats: true,
                                                   block: { (timer) in
                                                    self.updateTimeProgress()
                                                    if self.isCreatingClip && AudioManager.shared.progress >= self.progressSlider.editTo {
                                                      self.pausePlayer()
                                                      self.progressSlider.isPlayingInEditingMode = false
                                                      AudioManager.shared.currentTime = self.editFromTimeStepper.value
                                                    }
    })
  }
  
  private func updateTimeProgress() {
    currentTimeLabel.text = AudioManager.shared.currentTimeString
    progressSlider.progress = AudioManager.shared.progress
  }
  
  private func updateEditInterface() {
    let fromTime = TimeInterval(AudioManager.shared.duration! * Double(progressSlider.editFrom))
    editFromTimeLabel.text = fromTime.string(ms: true)
    editFromTimeStepper.value = fromTime
    let toTime = TimeInterval(AudioManager.shared.duration! * Double(progressSlider.editTo))
    editToTimeLabel.text = toTime.string(ms: true)
    editToTimeStepper.value = toTime
    progressSlider.progress = progressSlider.editFrom
  }
  
  
  // MARK: - Player controls
  
  @IBAction func playPause(_ sender: UIButton) {
    if AudioManager.shared.isPlaying { pausePlayer() } else { resumePlayer() }
  }
  
  private func pausePlayer() {
    AudioManager.shared.pause()
    updateTimeProgressTimer.invalidate()
    playPauseButton.setBackgroundImage(UIImage(named: "play"), for: .normal)
    if isCreatingClip {
      progressSlider.isPlayingInEditingMode = false
      AudioManager.shared.currentTime = editFromTimeStepper.value
      editFromTimeStepper.isEnabled = true
      editToTimeStepper.isEnabled = true
      clipCancelButton.isEnabled = true
      clipSaveButton.isEnabled = true
      backwardButton.isEnabled = false
      forwardButton.isEnabled = false
    }
  }
  
  private func resumePlayer() {
    AudioManager.shared.resume()
    startProgressTimer()
    playPauseButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
    if isCreatingClip {
      progressSlider.isPlayingInEditingMode = true
      AudioManager.shared.currentTime = editFromTimeStepper.value
      editFromTimeStepper.isEnabled = false
      editToTimeStepper.isEnabled = false
      clipCancelButton.isEnabled = false
      clipSaveButton.isEnabled = false
      backwardButton.isEnabled = true
      forwardButton.isEnabled = true
    }
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
    if !isCreatingClip {
      AudioManager.shared.setProgress(progressSlider.progress)  // TODO: Progress bar sometimes does not follow editFrom point
      updateTimeProgress()
    } else {
      updateEditInterface()  // TODO: Can drag knob while in editing mode
    }
  }
  
  
  // MARK: - Sharing
  
  @IBAction func share(_ sender: UIButton) {
    if AudioManager.shared.isPlaying { pausePlayer() }
    if let clip = AudioManager.shared.track as? Clip, let clipURL = clip.url {
      let epName = "Hey, check out this clip from \(clip.podcastName()!)!\nSent from the Podclips™ app"
      let shareActivityViewController = UIActivityViewController(activityItems: [epName, clipURL], applicationActivities: [])
      self.present(shareActivityViewController, animated: true, completion: nil)
    }
  }
  
  
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
    if AudioManager.shared.isPlaying { pausePlayer() }
    toggleClipEditorInterface()
    progressSlider.isPlayingInEditingMode = false
    
    editFromTimeStepper.minimumValue = 0
    editFromTimeStepper.maximumValue = AudioManager.shared.duration!
    editToTimeStepper.minimumValue = 0
    editToTimeStepper.maximumValue = AudioManager.shared.duration!
    
    progressSlider.editFrom = progressSlider.progress
    progressSlider.editTo = min(progressSlider.progress + 0.1, 1.0)
    
    updateEditInterface()
  }
  
  
  func toggleClipEditorInterface() {  // TODO: Stretch progress slider to zoom in on edit zone
    if !isCreatingClip {
      clipCancelButton.center.x -= 200
      editFromTimeStepper.center.x -= 200
      clipSaveButton.center.x += 200
      editToTimeStepper.center.x += 200
      clipCancelButton.isHidden = false
      clipSaveButton.isHidden = false
      editFromTimeStepper.isHidden = false
      editToTimeStepper.isHidden = false
      backwardButton.isEnabled = false
      forwardButton.isEnabled = false
    }
    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
      self.clipCancelButton.center.x += self.isCreatingClip ? -200 : 200
      self.editFromTimeStepper.center.x += self.isCreatingClip ? -200 : 200
      self.clipSaveButton.center.x += self.isCreatingClip ? 200 : -200
      self.editToTimeStepper.center.x += self.isCreatingClip ? 200 : -200
      self.controlButtonsView.center.y += self.isCreatingClip ? -40 : 40
      self.dismissButton.isHidden = !self.isCreatingClip
      self.clipButton.alpha = self.isCreatingClip ? 1 : 0
      self.bookmarkButton.alpha = self.isCreatingClip ? 1 : 0
      self.shareButton.alpha = self.isCreatingClip ? 1 : 0
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
        self.backwardButton.isEnabled = true
        self.forwardButton.isEnabled = true
      }
    }
    isCreatingClip = !isCreatingClip
    progressSlider.isInEditingMode = !progressSlider.isInEditingMode
  }
  
  @IBAction func cancelClip(_ sender: UIButton) {
    toggleClipEditorInterface()
  }
  
  @IBAction func saveClip(_ sender: UIButton) {
    let newClipAlert = UIAlertController.createNewItemAlert(title: "New Clip", message: "\(AudioManager.shared.episodeName!)\n\(AudioManager.shared.podcastName!)\n\(editFromTimeLabel.text!) - \(editToTimeLabel.text!)", cancelBlock: {
    }) { (comment) in
      self.saveClip(comment: comment)
    }
    self.present(newClipAlert, animated: true, completion: nil)
  }
  
  // TODO: Make this method more like saveBookmark
  private func saveClip(comment: String) {
    showSaveAlert(message: "Saving clip...")
    
    let asset = AVAsset(url: AudioManager.shared.url!)
    
    // Generate unique file name:
    var fileName = "Podclips_"
    fileName.append(AudioManager.shared.podcastName!.replacingOccurrences(of: " ", with: ""))
    let uuid = UUID().uuidString
    fileName.append("_\(uuid).m4a")
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
    let filemanager = FileManager.default
    if filemanager.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
      print("Error: Clip already exists!")
    }
    
    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
    exporter.outputFileType = AVFileType.m4a
    exporter.outputURL = trimmedSoundFileURL
    let fromTime = AudioManager.shared.duration! * Double(progressSlider.editFrom)
    let toTime = AudioManager.shared.duration! * Double(progressSlider.editTo)
    let startTime = CMTimeMake(Int64(fromTime*100), 100)
    let stopTime = CMTimeMake(Int64(toTime*100), 100)
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
  
  
  // MARK: - Editor controls
  
  @IBAction func editFromTimeStepperValueChanged(_ sender: UIStepper) {
    editFromTimeLabel.text = TimeInterval(editFromTimeStepper.value).string(ms: true)
    progressSlider.editFrom = Float(editFromTimeStepper.value/AudioManager.shared.duration!)
  }
  
  @IBAction func editToTimeStepperValueChanged(_ sender: UIStepper) {
    editToTimeLabel.text = TimeInterval(editToTimeStepper.value).string(ms: true)
    progressSlider.editTo = Float(editToTimeStepper.value/AudioManager.shared.duration!)
  }
  
  
  // MARK: - Alerts
  
  func showSaveAlert(message: String, dismiss: Bool = false) {
    saveAlert.title = message
    if self.presentedViewController == nil {
      present(saveAlert, animated: true, completion: nil)
    }
    if dismiss {
      Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false, block: { (timer) in
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
