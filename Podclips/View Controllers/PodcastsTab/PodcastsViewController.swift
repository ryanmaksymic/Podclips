//
//  PodcastsViewController.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-20.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import CoreData
import FeedKit

class PodcastsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var rssParser: RssfeedParser!
    var podcasts = [Podcast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEpisodes" {
            
            guard let dvc = segue.destination as? EpisodesViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedEpisodeCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedEpisodeCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
        }
    }
    
    @IBAction func unwindFromAddPodcastVC(_ sender: UIStoryboardSegue) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        if sender.source is AddPodcastViewController {
            if let senderVC = sender.source as? AddPodcastViewController {
                
                guard let feed = senderVC.rssURL else { return }
                rssParser = RssfeedParser(feed: feed)
                let podcastTuple = rssParser.getPodcast()
                let newPodcast = Podcast(context: managedContext)
                newPodcast.title = podcastTuple?.0
                newPodcast.rssfeed = URL(string: (podcastTuple?.1)!)
//                newPodcast.artwork = UIImagePNGRepresentation((podcastTuple?.2)!)
//                rssParser.getEpisodes()
                podcasts.append(newPodcast)
                tableView.reloadData()
                print("\(podcasts)")
            }
        }
    }

}

extension PodcastsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "podcastCell", for: indexPath) as! PodcastTableViewCell
        
        let podcast = podcasts[indexPath.row]
        
        // configure cell
        cell.titleLabel.text = podcast.title
        cell.artworkImageView.image = UIImage(data: podcast.artwork!)
        
        return cell
    }
}
