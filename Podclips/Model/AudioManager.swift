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
  
  var episodeName: String? {
    if let episode = track as? Episode {
      return episode.episodeName
    } else if let clip = track as? Clip {
      return clip.episode!.episodeName
    } else if let bookmark = track as? Bookmark {
      return bookmark.episode!.episodeName
    }
    return nil
  }
  
  var podcastName: String? {
    if let episode = track as? Episode {
      return episode.podcastName
    } else if let clip = track as? Clip {
      return clip.episode!.podcastName
    } else if let bookmark = track as? Bookmark {
      return bookmark.episode!.podcastName
    }
    return nil
  }
  
  var details: String? {
    if let episode = track as? Episode {
      return "Release Date: MM/dd/yyyy"  // TODO: Fill this in
    } else if let clip = track as? Clip {
      return clip.episode!.episodeName
    } else if let bookmark = track as? Bookmark {
      return bookmark.episode!.episodeName
    }
    return nil
  }
  
  var artwork: UIImage? {
    if let episode = track as? Episode {
      return UIImage(data: episode.artwork!)
    } else if let clip = track as? Clip {
      return UIImage(data: clip.episode!.artwork!)
    } else if let bookmark = track as? Bookmark {
      return UIImage(data: bookmark.episode!.artwork!)
    }
    return nil
  }
  
  var trackIsEpisode: Bool {
    if let _ = track as? Episode {
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
  
  
  // MARK: - Public methods
  
  func load(track: NSManagedObject) {
    self.track = track
    if let episode = track as? Episode {
      let episodeURL = URL.init(fileURLWithPath: Bundle.main.path(forResource: episode.fileName, ofType: "mp3")!)
      startPlaying(url: episodeURL, atTime: 0)
    } else if let clip = track as? Clip {
      print("Trying to play a clip!")
    } else if let bookmark = track as? Bookmark {
      print("Trying to play a bookmark!")
    }
    NotificationCenter.default.post(name: Notification.Name(R.AudioManagerUpdated), object: nil)
  }
  
  func startPlaying(url: URL, atTime time: Double) {
    do {
      player = try AVAudioPlayer(contentsOf: url)
    } catch {
      print(error)
      return
    }
    player?.currentTime = time
    player!.play()
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
