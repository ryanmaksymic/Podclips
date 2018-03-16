//
//  ProgressSlider.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-16.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

//class ProgressSlider: UIView {
class ProgressSlider: UIControl {
  
  // MARK: - Properties
  
  private var progressView: UIProgressView!
  private var knob: UIImageView!
  
  private var _progress: Float = 0.0
  
  public var progress: Float {
    get {
      return _progress
    }
    set {
      setProgress(value: newValue)
      knob.center.x = CGFloat(newValue) * self.frame.width
    }
  }
  
  public var minimumValue: Float = 0.0
  public var maximumValue: Float = 1.0

  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)!
    setupView()
  }
  
  
  // MARK: - Setup
  
  private func setupView() {
    setupProgressView()
    setupKnob()
    
    
  }
  
  func setupProgressView() {
    let margins = self.layoutMarginsGuide
    
    progressView = UIProgressView()
    addSubview(progressView)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    progressView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    progressView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    progressView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
  }
  
  func setupKnob() {
    knob = UIImageView(image: UIImage(named: "knob"))
    addSubview(knob)
    knob.translatesAutoresizingMaskIntoConstraints = false
    knob.widthAnchor.constraint(equalToConstant: 15).isActive = true
    knob.heightAnchor.constraint(equalToConstant: 35).isActive = true
    knob.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
    knob.centerXAnchor.constraint(greaterThanOrEqualTo: progressView.leadingAnchor).isActive = true
    knob.centerXAnchor.constraint(lessThanOrEqualTo: progressView.trailingAnchor).isActive = true
    
    let knobPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    knob.addGestureRecognizer(knobPanGestureRecognizer)
    
    knob.isUserInteractionEnabled = true
  }
  
  
  // MARK: - Actions
  
  public func setProgress(value: Float) {
    if value != _progress {
      _progress = min(maximumValue, max(minimumValue, value))
      progressView.progress = _progress
    }
  }
  
  
  // MARK: - Gestures
  
  @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
    let touchLocation = recognizer.location(in: self)
    if touchLocation.x > 0 && touchLocation.x < self.frame.width {
      recognizer.view!.center.x = touchLocation.x
      setProgress(value: Float(touchLocation.x/self.frame.width))
    }
    
    sendActions(for: .valueChanged)
    
    //    switch recognizer.state {
    //    case .began:
    //      //
    //    case .ended:
    //      //
    //    default:
    //      //
    //    }
  }
}
