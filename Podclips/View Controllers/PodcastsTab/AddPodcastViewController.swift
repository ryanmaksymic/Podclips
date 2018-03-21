//
//  AddPodcastViewController.swift
//  Podclips
//
//  Created by Yongwoo Huh on 2018-03-20.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

class AddPodcastViewController: UIViewController {
    @IBOutlet weak var urlTextField: UITextField!
    var rssURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let inputText = urlTextField.text, inputText.count > 0 else { return }
        
        rssURL = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
