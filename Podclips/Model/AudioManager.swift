//
//  AudioManager.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-14.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class AudioManager {
  
  // MARK: - Properties
  
  static var shared = AudioManager()
  
  private var player: AVAudioPlayer?
  
  var track: NSManagedObject?
  
  weak var delegate: AVAudioPlayerDelegate? {
    set {
      if let player = player {
        player.delegate = newValue
      }
    }
    get {
      if let player = player {
        return player.delegate
      }
      return nil
    }
  }
  
  var episodeName: String? {
    return track?.episodeName()
  }
  
  var podcastName: String? {
    return track?.podcastName()
  }
  
  var artwork: UIImage? {
    return track?.artwork()
  }
  
  var trackIsClip: Bool {
    if let _ = track as? Clip {
      return true
    }
    return false
  }
  
  var url: URL? {
    if let player = player {
      return player.url
    }
    return nil
  }
  
  var duration: Double? {
    if let player = player {
      return player.duration
    }
    return nil
  }
  
  var durationString: String? {
    if let player = player {
      return player.duration.string()
    }
    return nil
  }
  
  var currentTime: TimeInterval? {
    get {
      if let player = player {
        return player.currentTime
      }
      return nil
    }
    set {
      if let player = player {
        player.currentTime = newValue!
      }
    }
  }
  
  var currentTimeString: String? {
    if let player = player {
      return player.currentTime.string()
    }
    return nil
  }
  
  var progress: Float {
    if let player = player {
      return Float(player.currentTime/player.duration)
    }
    return 0
  }
  
  var isPlaying: Bool {
    if let player = player {
      return player.isPlaying
    }
    return false
  }
  
  var isTrackLoaded: Bool = false
  
  
  // MARK: - Public methods
  
  func load(track: NSManagedObject) {
    self.track = track
    if let episode = track as? Episode {
      let episodeURL = URL.init(fileURLWithPath: Bundle.main.path(forResource: episode.fileName, ofType: "mp3")!)
      startPlaying(url: episodeURL, atTime: 0)
    } else if let clip = track as? Clip {
      startPlaying(url: clip.url!, atTime: 0)
    } else if let bookmark = track as? Bookmark {
      let episodeURL = URL.init(fileURLWithPath: Bundle.main.path(forResource: bookmark.episode!.fileName, ofType: "mp3")!)
      startPlaying(url: episodeURL, atTime: bookmark.timestamp)
    }
    NotificationCenter.default.post(name: Notification.Name(R.NewSongLoaded), object: nil)
    isTrackLoaded = true
  }
  
  func pause() {
    if let player = player {
      player.pause()
    }
  }
  
  func resume() {
    if let player = player {
      player.play()
    }
  }
  
  func forward(_ time: Double) {
    if let player = player {
      player.currentTime += time
    }
  }
  
  func backward(_ time: Double) {
    if let player = player {
      player.currentTime -= time
    }
  }
  
  func setProgress(_ newValue: Float) {
    if let player = player {
      player.currentTime = player.duration * Double(newValue)
    }
  }
  
  
  // MARK: - Private methods
  
  private func startPlaying(url: URL, atTime time: Double) {
    do {
      player = try AVAudioPlayer(contentsOf: url)
    } catch {
      print(error)
      return
    }
    player?.currentTime = time
    player!.play()
  }
}


// MARK: - TimeInterval extension

extension TimeInterval {
  func string(ms: Bool = false) -> String {
    var result = ""
    let hours = Int(self/3600)
    let minutes = Int((self / 60).truncatingRemainder(dividingBy: 60))
    let seconds = Int(self.truncatingRemainder(dividingBy: 60))
    let milliseconds = Int(self.truncatingRemainder(dividingBy: 1) * 10)
    result.append(hours < 10 ? "0\(hours)" : "\(hours)")
    result.append(minutes < 10 ? ":0\(minutes)" : ":\(minutes)")
    result.append(seconds < 10 ? ":0\(seconds)" : ":\(seconds)")
    if ms { result.append(":\(milliseconds)0") }
    return result
  }
}


// MARK: - NSManagedObject extension

extension NSManagedObject {
  
  func episodeName() -> String? {
    if let episode = self as? Episode {
      return episode.episodeName
    } else if let clip = self as? Clip {
      return "Clip from \"\(clip.episode!.episodeName!)\""
    } else if let bookmark = self as? Bookmark {
      return bookmark.episode!.episodeName
    }
    return nil
  }
  
  func podcastName() -> String? {
    if let episode = self as? Episode {
      return episode.podcastName
    } else if let clip = self as? Clip {
      return clip.episode!.podcastName
    } else if let bookmark = self as? Bookmark {
      return bookmark.episode!.podcastName
    }
    return nil
  }
  
  func details() -> String? {
    if let episode = self as? Episode {
      return "Release Date: MM/dd/yyyy"  // TODO: Fill this in
    } else if let clip = self as? Clip {
      return clip.comment
    } else if let bookmark = self as? Bookmark {
      return bookmark.comment
    }
    return nil
  }
  
  func artwork() -> UIImage? {
    if let episode = self as? Episode {
      return UIImage(data: episode.artwork!)
    } else if let clip = self as? Clip {
      return UIImage(data: clip.episode!.artwork!)
    } else if let bookmark = self as? Bookmark {
      return UIImage(data: bookmark.episode!.artwork!)
    }
    return nil
  }
  
  func timeInfo() -> String? {
    if let episode = self as? Episode {
      return episode.durationString
    } else if let clip = self as? Clip {
      return clip.durationString
    } else if let bookmark = self as? Bookmark {
      return bookmark.timestampString
    }
    return nil
  }
}
