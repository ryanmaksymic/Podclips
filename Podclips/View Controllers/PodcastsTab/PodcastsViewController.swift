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
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var managedObjectContext: NSManagedObjectContext!
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Podcast> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Podcast> = Podcast.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Podcast.title), ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        managedObjectContext.automaticallyMergesChangesFromParent = true
        
        fetchPodcasts()
      
        self.navigationItem.titleView = UIImageView.init(image: UIImage(named: "logo"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "listEpisodes" {
            
            guard let destination = segue.destination as? EpisodesViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedEpisodeCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedEpisodeCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // Fetch Podcast
            let podcast = fetchedResultsController.object(at: indexPath)
            
            destination.podcast = podcast
        }
    }
    
    // MARK: - IBActions
    @IBAction func unwindFromAddPodcastVC(_ sender: UIStoryboardSegue) {
        
        if sender.source is AddPodcastViewController, let senderVC = sender.source as? AddPodcastViewController {
            
            guard let feed = senderVC.rssURL else { return }
            rssParser = RssfeedParser(feed: feed)
            guard let podcastTuple = rssParser.getPodcast() else { return }
            let newPodcast = Podcast(context: managedObjectContext)
            newPodcast.title = podcastTuple.0
            newPodcast.rssfeed = URL(string: podcastTuple.1)
            
            // get podcast artwork
            let imageURL = podcastTuple.2
            getPodcastImage(imageURL: imageURL, completion: { (image) in
                newPodcast.artwork = UIImagePNGRepresentation(image)
                
            })
            rssParser.getEpisodes(podcast: newPodcast, context: managedObjectContext)
            appDelegate?.saveContext()
        }
    }
    
    // MARK: - Private Methods
    private func fetchPodcasts() {
        // Peform Fetch Request
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
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

// MARK: - TableView Data source
extension PodcastsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "podcastCell", for: indexPath) as! PodcastTableViewCell
        
        // Fetch Podcast
        let podcast = fetchedResultsController.object(at: indexPath)
        
        // configure cell
        if let title = podcast.title, let artworkData = podcast.artwork {
            cell.titleLabel.text = title
            cell.artworkImageView.layer.cornerRadius = 4.0
            cell.artworkImageView.image = UIImage(data: artworkData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Podcast
        let podcast = fetchedResultsController.object(at: indexPath)
        
        // Delete Note
        managedObjectContext.delete(podcast)
        appDelegate?.saveContext()
    }
}

extension PodcastsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? PodcastTableViewCell {
                appDelegate?.saveContext()
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
    
}
