//
//  PodcastCellViewModel.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

struct PodcastCellViewModel {
    let trackNameText: String?
    let artistNameText: String?
    let numberOfEpisodesText: String
    let thumnailUrl: URL?
}

extension PodcastCellViewModel {
    init(podcast: Podcast) {
        self.trackNameText = podcast.trackName
        self.artistNameText = podcast.artistName
        self.numberOfEpisodesText = String(podcast.trackCount ?? 0)
        
        if let url = URL(string: podcast.artworkUrl600 ?? "") {
           self.thumnailUrl = url
        } else {
            self.thumnailUrl = nil
        }
    }
}
