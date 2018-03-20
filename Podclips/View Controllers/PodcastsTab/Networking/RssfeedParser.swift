//
//  RssfeedParser.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-20.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import FeedKit

class RssfeedParser {
    var podcastFeed: String
    var rssfeed: FeedKit.RSSFeed!
    
    init(feed: String) {
        self.podcastFeed = feed
    }
    
    func getPodcast() -> (title: String, feed: String, artwork: UIImage)? {
        guard let feedURL = URL(string: podcastFeed), let parser = FeedParser(URL: feedURL) else {
            print("could not change string to URL")
            return nil
        }
        let result = parser.parse()
        guard let feed = result.rssFeed, result.isSuccess else {
            print(result.error ?? NSError.self)
            return nil
        }
        
        guard let podcastTitle =  feed.title else { return nil }
        guard let itunes = feed.iTunes, let image = itunes.iTunesImage, let imageAtt = image.attributes,
            let podImageURLString = imageAtt.href,
            let podImageURL = URL(string: podImageURLString) else { return nil }
        var podcastImage = UIImage()
//        getPodcastImage(imageURL: podImageURL, completion: { (image) in
//            podcastImage = image
//        })
        
        // Make Podcast with self.feed, podcastTitle, podcastImage
        return (podcastTitle, podcastFeed, podcastImage)

    }
    
    func getEpisodes() {
        // get 20 episodes from the rssfeed
        
    }
    
    func getNewEpisodes() {
        
    }
    
    // Private Methods
    private func getPodcastImage(imageURL: URL, completion: @escaping (UIImage) -> Void) {
        let request = URLRequest(url: imageURL)
        let defaultSession = URLSession(configuration: .default)
        let task = defaultSession.downloadTask(with: request) { (url, response, error) in
            guard error == nil else {
                print("Error with download task")
                return
            }
            guard let url = url else {
                print("Could not get image URL")
                return
            }
            let statusCode = (response as! HTTPURLResponse).statusCode
            guard statusCode == 200 else {
                print(#line, statusCode)
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    return
                }
                completion(image)
            }
            catch {
                print(#line, error.localizedDescription)
            }
            
            DispatchQueue.main.async {
    
            }
        }
        task.resume()
    }
}

