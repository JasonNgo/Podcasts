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
  
  static func initFromNib() -> UINib {
    return UINib(nibName: "PodcastCell", bundle: nil)
  }
  
  var podcast: Podcast! {
    didSet {
      trackLabel.text = podcast.trackName
      artistLabel.text = podcast.artistName
      numEpisodesLabel.text = "\(podcast.trackCount ?? 0) Episodes "
      
      print("Loading image with url: \(podcast.artworkUrl600 ?? "")")
      guard let podcastArtUrl = URL(string: podcast.artworkUrl600 ?? "") else { return }
      thumbnailImageView.sd_setImage(with: podcastArtUrl, completed: nil)
    }
  }
  
} // PodcastCell
