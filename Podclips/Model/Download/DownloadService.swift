//
//  DownloadService.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-21.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import Foundation

// Downloads song snippets, and stores in local file.
// Allows cancel, pause, resume download.
class DownloadService {
    var activeDownloads: [URL: Download] = [:]
    
    // SearchViewController creates downloadsSession
    var downloadsSession: URLSession!
    
    // MARK: - Download methods called by PlaylistCell delegate methods
    
    func startDownload(_ episode: Episode) {
        // 1
        let download = Download(episode: episode)
        // 2
        guard let fileURL = episode.fileURL else { return }
        download.task = downloadsSession.downloadTask(with: fileURL)
        // 3
        download.task!.resume()
        // 4
        download.isDownloading = true
        // 5
        activeDownloads[download.episode.fileURL!] = download
    }
    
    func pauseDownload(_ episode: Episode) {
        // TODO
    }
    
    func cancelDownload(_ episode: Episode) {
        // TODO
    }
    
    func resumeDownload(_ episode: Episode) {
        // TODO
    }
    
}

