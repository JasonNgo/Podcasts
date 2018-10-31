//
//  PodcastCell.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var numEpisodesLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackLabel.text = podcast.trackName
            artistLabel.text = podcast.artistName
            numEpisodesLabel.text = "\(podcast.trackCount ?? 0) Episodes "
            
            print("Loading image with url: \(podcast.artworkUrl600 ?? "")")
            
            guard let podcastArtUrl = URL(string: podcast.artworkUrl600 ?? "") else { return }
            
            // Swift way to fetch image
//            URLSession.shared.dataTask(with: url) { (data, response, error) in
//                if let err = error {
//                    print("There was an error fetching the image for url: \(url)", err)
//                    return
//                }
//
//                guard let unwrappedData = data else { return }
//
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: unwrappedData)
//                }
//            }.resume()
            
            // SD image way to fetch image and cache it
            thumbnailImageView.sd_setImage(with: podcastArtUrl, completed: nil)
        }
    }
    
} // PodcastCell
