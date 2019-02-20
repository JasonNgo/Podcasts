//
//  FavouriteCellViewModel.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-15.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

struct FavouriteCellViewModel {
    let titleText: String?
    let authorText: String?
    let thumbnailUrl: URL?
}

extension FavouriteCellViewModel {
    init(podcast: Podcast) {
        self.titleText = podcast.trackName
        self.authorText = podcast.artistName
        
        if let url = URL(string: podcast.artworkUrl600 ?? "") {
            self.thumbnailUrl = url
        } else {
            self.thumbnailUrl = nil
        }
    }
}
