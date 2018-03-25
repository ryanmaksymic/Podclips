//
//  Download.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-21.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import Foundation

class Download {
    
    var episode: Episode
    init(episode: Episode) {
        self.episode = episode
    }
    
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    
    // Download delegate sets this value:
    var progress: Float = 0
    
}

