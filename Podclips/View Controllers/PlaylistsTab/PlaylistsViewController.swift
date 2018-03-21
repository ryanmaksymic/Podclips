//
//  PlaylistsViewController.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-20.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import CoreData

class PlaylistsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var playlist: Playlist?
    
    // Core Data
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private var managedObjectContext: NSManagedObjectContext!
    private var fetchedResultsController: NSFetchedResultsController<Episode>!
    
    // Download
    let downloadService = DownloadService()
    // Create downloadsSession here, to set self as delegate
    lazy var downloadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Core Data
        managedObjectContext = appDelegate?.persistentContainer.viewContext
        managedObjectContext.automaticallyMergesChangesFromParent = true
        setupPlaylist()
        fetchEpisodes()
        
        // download
        downloadService.downloadsSession = downloadsSession
      
        self.navigationItem.titleView = UIImageView.init(image: UIImage(named: "logo"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchEpisodes()
        tableView.reloadData()
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
    private func setupPlaylist() {
        // fetch playlist
        if !fetchPlaylist() {
            playlist = Playlist(context: managedObjectContext)
            playlist?.name = "All Episodes"
            appDelegate?.saveContext()
        }
    }
    
    private func fetchPlaylist() -> Bool {
        // fetch playlist
        let managedObjectContext = self.managedObjectContext
        let fetchRequest: NSFetchRequest<Playlist> = Playlist.fetchRequest()
        do {
            let playlists = try managedObjectContext?.fetch(fetchRequest)
            playlist = playlists?.first
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
        
        return (playlist != nil)
    }
    
    private func fetchEpisodes() {
        
        fetchedResultsController =  {
            guard let managedObjectContext = self.playlist?.managedObjectContext else {
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
        // fetch episodes with the same value in playlist colum as "All Episodes" playlist
        let predicate = NSPredicate(format: "%K == 1", "playlist")
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            
            try fetchedResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
}

extension PlaylistsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistTableViewCell
        
        let episode = fetchedResultsController.object(at: indexPath)
        
        cell.onDownloadTapped = { (cell) in
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            
            // start download
            self.downloadService.startDownload(episode)
            self.reload(indexPath.row)
        }
        
        // configure cell
        cell.titleLabel.text = episode.episodeName
      
        cell.artworkImageView.layer.cornerRadius = 4.0
        //cell.artworkImageView.clipsToBounds = true
        cell.artworkImageView.image = UIImage(data: episode.podcast!.artwork!) ?? UIImage(named: "artwork")
        
        return cell
    }

}


extension PlaylistsViewController: NSFetchedResultsControllerDelegate {
 
}

extension PlaylistsViewController: PlaylistTableViewCellDelegate {

    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }    
    
}
