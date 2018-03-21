//
//  RssfeedParser.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-20.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import FeedKit
import CoreData

class RssfeedParser {
    var podcastFeed: String
    var rssfeed: FeedKit.RSSFeed!
    
    init(feed: String) {
        self.podcastFeed = feed
    }
    
    func getPodcast() -> (title: String, feed: String, imageURL: URL)? {
        guard let feedURL = URL(string: podcastFeed), let parser = FeedParser(URL: feedURL) else {
            print("could not change string to URL")
            return nil
        }
        let result = parser.parse()
        guard let feed = result.rssFeed, result.isSuccess else {
            print(result.error ?? NSError.self)
            return nil
        }
        rssfeed = feed
        
        guard let podcastTitle =  feed.title else { return nil }
        guard let itunes = feed.iTunes, let image = itunes.iTunesImage, let imageAtt = image.attributes,
            let podImageURLString = imageAtt.href,
            let podImageURL = URL(string: podImageURLString) else { return nil }
//        var podcastImage = UIImage()
//        getPodcastImage(imageURL: podImageURL, completion: { (image) in
//            podcastImage = image
//        })
        
        return (podcastTitle, podcastFeed, podImageURL)
    }
    
    func getEpisodes(podcast: Podcast, context: NSManagedObjectContext){
        
        // add episodes to podcast episodes array(max 20)
        if let items = rssfeed.items {
            // parse episode
            for item in items {
                
                if items.index(of: item) == 20 {
                    break
                }

                let episode = Episode(context: context)
                // title
                guard let title = item.title else { return }
                
                // pubDate
                guard let pubDate = item.pubDate else { return }
                
                // mp3url
                guard let enclosure = item.enclosure, let attributes = enclosure.attributes,
                    let mp3URLString = attributes.url else { return }
                
                // duration
                guard let iTunes = item.iTunes, let duration = iTunes.iTunesDuration else { return }
                
                // make Episode object with attributes
                episode.episodeName = title
                episode.pubDate = pubDate
                episode.durationString = secToString(duration)
                episode.fileName = mp3URLString
                episode.progress = 0.0
                episode.podcastName = podcast.title
                
                // add Episode object to Episode set
                podcast.addToEpisodes(episode)
            }
        }

    }
    
    func updateRssfeed() {
        
    }
    
    // Private Methods
    private func secToString(_ duration: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(duration))!
        return formattedString
    }
}

