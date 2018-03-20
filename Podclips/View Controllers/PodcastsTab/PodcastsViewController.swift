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
                guard let podcastTuple = rssParser.getPodcast() else { return }
                let newPodcast = Podcast(context: managedContext)
                newPodcast.title = podcastTuple.0
                newPodcast.rssfeed = URL(string: podcastTuple.1)
               
                // get podcast artwork
                let imageURL = podcastTuple.2
                getPodcastImage(imageURL: imageURL, completion: { (image) in
                    newPodcast.artwork = UIImagePNGRepresentation(image)
                    self.podcasts.append(newPodcast)
                })
            }
        }
    }
    
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
                self.tableView.reloadData()
            }
        }
        task.resume()
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
        
        if let data = podcast.artwork {
            cell.artworkImageView.image = UIImage(data: data)
        }
        
        return cell
    }
}
