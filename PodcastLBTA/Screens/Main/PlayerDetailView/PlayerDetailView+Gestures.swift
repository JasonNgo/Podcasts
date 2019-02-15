/***
 Copyright (c) 2018 Jason Ngo
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 ***/

//
//  PlayerDetailView+Gestures.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-14.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

extension PlayerDetailView {
  
  @objc func handleExpand() {
    UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
  }
  
  @objc func handlePan(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .changed:
      handlePanChanged(gesture: gesture)
    case .ended:
      handlePanEnded(gesture: gesture)
    default:
      break
    }
  }
  
  func handlePanChanged(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: superview)
    transform = CGAffineTransform(translationX: 0, y: translation.y)
    
    minimizedPlayerView.alpha = 1 + translation.y / 200
    maximizedStackView.alpha = -translation.y / 200
  }
  
  func handlePanEnded(gesture: UIPanGestureRecognizer) {
    let handlePanEndedClosure = {
      self.transform = .identity
      
      let translation = gesture.translation(in: self.superview)
      let velocity = gesture.velocity(in: self.superview)
      
      if translation.y < -200 || velocity.y < -500 {
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
      } else {
        self.minimizedPlayerView.alpha = 1
        self.maximizedStackView.alpha = 0
      }
    }
    
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 1,
      options: .curveEaseOut,
      animations: {
        handlePanEndedClosure()
    })
  }
  
  @objc func handleMaximizedPan(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .changed:
      handleMaximizedPanGestureChanged(gesture: gesture)
    case .ended:
      handleMaximizedPanGestureEnded(gesture: gesture)
    default:
      break
    }
  }
  
  func handleMaximizedPanGestureChanged(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: superview)
    transform = CGAffineTransform(translationX: 0, y: translation.y)
  }
  
  func handleMaximizedPanGestureEnded(gesture: UIPanGestureRecognizer) {
    let handleMaximizedPanClosure = {
      self.transform = .identity
      let translation = gesture.translation(in: self.superview)
      let velocity = gesture.velocity(in: self.superview)
      if translation.y > 50 || velocity.y > 500 {
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
      }
    }
    
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 1,
      options: .curveEaseOut,
      animations: {
        handleMaximizedPanClosure()
    })
  }
  
}
