//
//  EpisodeCellViewModel.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

struct EpisodeCellViewModel {
    let titleText: String
    let descriptionText: String
    let publicationDateText: String
    let thumbnailUrl: URL?
    
    let df: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter
    }()
}

extension EpisodeCellViewModel {
    init(episode: Episode) {
        self.titleText = episode.title
        self.descriptionText = episode.description
        self.publicationDateText = df.string(from: episode.pubDate)
        
        if let imageUrl = episode.imageUrl,
            let url = URL(string: imageUrl.toSecureHTTPS()) {
            self.thumbnailUrl = url
        } else {
            self.thumbnailUrl = nil
        }
    }
}
