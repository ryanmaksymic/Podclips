//
//  PlaylistVc+URLSessionDelegate.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-21.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import Foundation
import CoreData

extension PlaylistsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        // 2
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.episode.downloaded = true
            download?.episode.fileURL = destinationURL
            appDelegate?.saveContext()
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
