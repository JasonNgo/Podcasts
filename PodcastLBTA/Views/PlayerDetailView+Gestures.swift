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
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        self.minimizedPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            
            let translation = gesture.translation(in: self.superview)
            let velocity = gesture.velocity(in: self.superview)
            
            if translation.y < -200 || velocity.y < -500 {
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
            } else {
                self.minimizedPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
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
    } // handleMaximizedPan(gesture:)
    
    func handleMaximizedPanGestureChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
    }
    
    func handleMaximizedPanGestureEnded(gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            
            let translation = gesture.translation(in: self.superview)
            let velocity = gesture.velocity(in: self.superview)
            
            if translation.y > 50 || velocity.y > 500 {
                UIApplication.mainTabBarController()?.minimizePlayerDetails()
            }
        })
    }
    
} // PlayerDetailView+Gesture
