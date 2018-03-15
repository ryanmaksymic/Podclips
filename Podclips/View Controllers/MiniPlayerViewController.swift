//
//  MiniPlayerViewController.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-14.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class MiniPlayerViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var episodeNameLabel: UILabel!
  @IBOutlet weak var podcastNameLabel: UILabel!
  @IBOutlet weak var detailsLabel: UILabel!
  @IBOutlet weak var playPauseButton: UIButton!
  
  
  // MARK: - Properties
  
  //var track: NSManagedObject?
  
  
  // MARK: - Setup
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInterface()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    setupInterface()
  }
  
  // TODO: Set up some communication pattern where this is called whenever AudioManager starts or stops
  private func setupInterface() {
    artworkImageView.image = AudioManager.shared.artwork ?? UIImage(named: "artwork")
    episodeNameLabel.text = AudioManager.shared.episodeName ?? ""
    podcastNameLabel.text = AudioManager.shared.podcastName ?? "No media selected"
    detailsLabel.text = AudioManager.shared.details ?? ""
    artworkImageView.layer.cornerRadius = 4.0
    artworkImageView.clipsToBounds = true
  }
  
  
  // MARK: - Touches
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    performSegue(withIdentifier: "PresentPlayer", sender: nil)
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
