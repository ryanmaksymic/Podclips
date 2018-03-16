//
//  ProgressSlider.swift
//  Podclips
//
//  Created by Ryan Maksymic on 2018-03-16.
//  Copyright © 2018 Ryan Maksymic. All rights reserved.
//

import UIKit

@IBDesignable class ProgressSlider: UIControl {
  
  // MARK: - Properties
  
  private var progressView: UIProgressView!
  
  private var knob: UIImageView!
  private var knobCenterXConstraint: NSLayoutConstraint!
  private var leftHandle: UIImageView!
  private var leftHandleCenterXConstraint: NSLayoutConstraint!
  private var rightHandle: UIImageView!
  private var rightHandleCenterXConstraint: NSLayoutConstraint!
  private var editZone: UIImageView!
  let handleWidth: CGFloat = 25
  
  private var _progress: Float = 0.0
  public var progress: Float {
    get {
      return _progress
    }
    set {
      setProgress(newValue)
      knob.center.x = handleWidth + CGFloat(newValue) * progressView.frame.width
    }
  }
  public var minimumProgress: Float = 0.0
  public var maximumProgress: Float = 1.0
  
  private var _isInEditingMode = false
  public var isInEditingMode: Bool! {
    get {
      return _isInEditingMode
    }
    set {
      setIsInEditingMode(newValue)
      knob.isHidden = newValue
      leftHandle.isHidden = !newValue
      rightHandle.isHidden = !newValue
      editZone.isHidden = !newValue
    }
  }
  
  public var editFrom: Float {
    return Float((editZone.frame.minX - progressView.frame.minX)/progressView.frame.width)
  }
  
  public var editTo: Float {
    return Float((editZone.frame.maxX - progressView.frame.minX)/progressView.frame.width)
  }
  
  
  // MARK: - Setter methods
  
  private func setProgress(_ value: Float) {
    if value != _progress {
      _progress = min(maximumProgress, max(minimumProgress, value))
      progressView.progress = _progress
    }
  }
  
  private func setIsInEditingMode(_ value: Bool) {
    if value != _isInEditingMode {
      _isInEditingMode = value
    }
  }
  
  
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
    setupEditor()
  }
  
  func setupProgressView() {
    progressView = UIProgressView()
    addSubview(progressView)
    progressView.translatesAutoresizingMaskIntoConstraints = false
    progressView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    progressView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    progressView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: +handleWidth).isActive = true
    progressView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -handleWidth).isActive = true
  }
  
  func setupKnob() {
    knob = UIImageView(image: UIImage(named: "knob"))
    addSubview(knob)
    knob.translatesAutoresizingMaskIntoConstraints = false
    knob.widthAnchor.constraint(equalToConstant: 15).isActive = true
    knob.heightAnchor.constraint(equalToConstant: 35).isActive = true
    knob.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
    knobCenterXConstraint = knob.centerXAnchor.constraint(equalTo: progressView.leftAnchor, constant: 0)
    knobCenterXConstraint.isActive = true
    
    let knobPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    knob.addGestureRecognizer(knobPanGestureRecognizer)
    knob.isUserInteractionEnabled = true
    
    knob.isHidden = false
  }
  
  func setupEditor() {
    leftHandle = UIImageView(image: UIImage(named: "handle"))
    addSubview(leftHandle)
    leftHandle.translatesAutoresizingMaskIntoConstraints = false
    leftHandle.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
    leftHandle.heightAnchor.constraint(equalToConstant: 35).isActive = true
    leftHandle.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
    leftHandleCenterXConstraint = leftHandle.centerXAnchor.constraint(equalTo: progressView.leftAnchor, constant: -handleWidth/2)
    leftHandleCenterXConstraint.isActive = true
    
    let leftHandlePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    leftHandle.addGestureRecognizer(leftHandlePanGestureRecognizer)
    leftHandle.isUserInteractionEnabled = true
    
    rightHandle = UIImageView(image: UIImage(named: "handle"))
    addSubview(rightHandle)
    rightHandle.translatesAutoresizingMaskIntoConstraints = false
    rightHandle.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
    rightHandle.heightAnchor.constraint(equalToConstant: 35).isActive = true
    rightHandle.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
    rightHandleCenterXConstraint = rightHandle.centerXAnchor.constraint(equalTo: progressView.leftAnchor, constant: 100)
    rightHandleCenterXConstraint.isActive = true
    
    let rightHandlePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    rightHandle.addGestureRecognizer(rightHandlePanGestureRecognizer)
    rightHandle.isUserInteractionEnabled = true
    
    editZone = UIImageView(image: UIImage(named: "editZone"))
    addSubview(editZone)
    sendSubview(toBack: editZone)
    editZone.translatesAutoresizingMaskIntoConstraints = false
    editZone.heightAnchor.constraint(equalToConstant: 10).isActive = true
    editZone.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
    editZone.leftAnchor.constraint(equalTo: leftHandle.centerXAnchor, constant: handleWidth/2).isActive = true
    editZone.rightAnchor.constraint(equalTo: rightHandle.centerXAnchor, constant: -handleWidth/2).isActive = true
    
    leftHandle.isHidden = true
    rightHandle.isHidden = true
    editZone.isHidden = true
  }
  
  
  // MARK: - Gestures
  
  // TODO: Clean all of this up
  @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
    let touchLocation = recognizer.location(in: self)
    if recognizer.view == knob {
      if touchLocation.x > handleWidth && touchLocation.x < self.frame.width - handleWidth {
        setProgress(Float((touchLocation.x - handleWidth)/progressView.frame.width))
        knobCenterXConstraint.constant = touchLocation.x - handleWidth
      }
    }
    else if recognizer.view == leftHandle {
      if touchLocation.x >= handleWidth/2 && touchLocation.x < rightHandle.center.x - handleWidth {
        leftHandleCenterXConstraint.constant = touchLocation.x - handleWidth
      }
    }
    else if recognizer.view == rightHandle {
      if touchLocation.x <= self.frame.width - handleWidth/2 && touchLocation.x > leftHandle.center.x + handleWidth {
        rightHandleCenterXConstraint.constant = touchLocation.x - handleWidth
      }
    }
    sendActions(for: .valueChanged)
  }
}
