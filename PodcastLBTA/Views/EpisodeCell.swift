//
//  EpisodeCell.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-13.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var publicationDateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var downloadProgressLabel: UILabel!
    
    let df: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter
    }()
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            publicationDateLabel.text = df.string(from: episode.pubDate)
            
            guard let unwrappedImageUrl = episode.imageUrl else { return }
            guard let url = URL(string: unwrappedImageUrl.toSecureHTTPS()) else { return }
            
            thumbnailImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
} // EpisodeCell
