//
//  PlayerDetailView.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-13.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class PlayerDetailView: UIView {
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            playerImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func handleDismissPressed(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
} // PlayerDetailView
