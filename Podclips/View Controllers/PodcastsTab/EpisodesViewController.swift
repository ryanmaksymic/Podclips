//
//  EpisodesViewController.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-20.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import CoreData

class EpisodesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var podcast: Podcast?
    var playlist: Playlist?
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var fetchedResultsController: NSFetchedResultsController<Episode> = {
        guard let managedObjectContext = self.podcast?.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Episode> = Episode.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pubDate", ascending: false)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEpisodes()
        setupPlaylist()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Private Methods
    private func fetchEpisodes() {
        let predicate = NSPredicate(format: "podcastName == %@", (podcast?.title)! )
        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            
            try fetchedResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    private func setupPlaylist() {
        // fetch playlist
        if !fetchPlaylist() {
            playlist = Playlist(context: (podcast?.managedObjectContext)!)
            playlist?.name = "All Episodes"
            appDelegate?.saveContext()
        }
    }
    
    private func fetchPlaylist() -> Bool {
        // fetch playlist
        let managedObjectContext = podcast?.managedObjectContext
        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        do {
            let playlists = try managedObjectContext?.fetch(fetchRequest)
            playlist = playlists?.first
            //            print("\(String(describing: playlist.name))")
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
        
        return (playlist != nil)
    }
    
}

// MARK: - TableView Data Source
extension EpisodesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath) as! EpisodeTableViewCell
        
        let episode = fetchedResultsController.object(at: indexPath)
        
        cell.onButtonTapped = { (cell) in
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            print("download button tapped on \(indexPath)")
            
            // add to playlist
            self.playlist?.addToEpisodes(episode)
            self.appDelegate?.saveContext()
        }
        
        // configure cell
        cell.titleLabel.text = episode.episodeName
        cell.pubDateLabel.text = episode.pubDate?.description
        cell.durationLabel.text = episode.durationString
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension EpisodesViewController: NSFetchedResultsControllerDelegate {
    
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? EpisodeTableViewCell {
                // configure cell
                tableView.reloadData()
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

