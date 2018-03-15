//
//  UIAlertController+CustomAlert.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-15.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

extension UIAlertController {
  
  class func createNewItemAlert(title: String, message: String, cancelBlock: @escaping () -> (), saveBlock: @escaping (String) -> ()) -> UIAlertController {
    
    let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    
    alert.addTextField { (textField) in
      textField.placeholder = "Add a comment if you like"
      textField.textAlignment = .center
      textField.autocapitalizationType = .sentences
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
      cancelBlock()
    }))
    
    alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
      saveBlock(alert.textFields!.first!.text!)
    }))
    
    return alert
  }
}
