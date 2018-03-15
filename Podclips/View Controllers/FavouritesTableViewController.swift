//
//  FavouritesTableViewController.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-14.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import CoreData

class FavouritesTableViewController: UITableViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  
  // MARK: - Properties
  
  private var tracks = [NSManagedObject]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadTracks()
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  
  // MARK: - Private methods
  
  private func loadTracks() {
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      if let bookmarks = DataManager.load(entities: R.Bookmark) as? [Bookmark] {
        self.tracks = bookmarks
      }
    case 1:
      if let clips = DataManager.load(entities: R.Clip) as? [Clip] {
        self.tracks = clips
      }
    case 2:
      guard let episodes = DataManager.load(entities: R.Episode) as? [Episode], episodes != [] else {
        print("No episodes found. Creating dummy data.")
        generateDummyData()
        loadTracks()
        return
      }
      self.tracks = episodes
    default:
      self.tracks = []
    }
  }
  
  private func generateDummyData() {
    let episode1Data: [String:Any] = [
      R.artwork:UIImageJPEGRepresentation(UIImage(named: "ra.jpg")!, 1)!,
      R.episodeName:"#102 Long Distance",
      R.podcastName:"Reply All",
      R.progress:0,
      R.fileName: "RA",
      R.durationString: "01:23:45"]
    _ = DataManager.create(entity: R.Episode, withData: episode1Data)
    let episode2Data: [String:Any] = [
      R.artwork:UIImageJPEGRepresentation(UIImage(named: "hh.jpg")!, 1)!,
      R.episodeName:"Episode #456",
      R.podcastName:"Hollywood Handbook",
      R.progress:0,
      R.fileName: "HH",
      R.durationString: "01:23:45"]
    _ = DataManager.create(entity: R.Episode, withData: episode2Data)
    let episode3Data: [String:Any] = [
      R.artwork:UIImageJPEGRepresentation(UIImage(named: "utu2tm.jpg")!, 1)!,
      R.episodeName:"Episode #789",
      R.podcastName:"U Talkin' U2 To Me?",
      R.progress:0,
      R.fileName:"UTU2TM",
      R.durationString: "01:23:45"]
    _ = DataManager.create(entity: R.Episode, withData: episode3Data)
    let episode4Data: [String:Any] = [
      R.artwork:UIImageJPEGRepresentation(UIImage(named: "cbb.jpg")!, 1)!,
      R.episodeName:"Episode #123",
      R.podcastName:"Comedy Bang! Bang!",
      R.progress:0,
      R.fileName: "CBB",
      R.durationString: "01:23:45"]
    _ = DataManager.create(entity: R.Episode, withData: episode4Data)
  }
  
  
  // MARK: - UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavouritesTableViewCell
    
    let track = tracks[indexPath.row]
    
    cell.episodeNameLabel.text = track.episodeName()
    cell.podcastNameLabel.text = track.podcastName()
    cell.detailsLabel.text = track.details()
    cell.timeLabel.text = track.timeInfo()
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let track = tracks[indexPath.row]
    AudioManager.shared.load(track: track)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  
  // MARK: - Segmented control
  
  @IBAction func segmentedControl(_ sender: UISegmentedControl) {
    loadTracks()
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
}
