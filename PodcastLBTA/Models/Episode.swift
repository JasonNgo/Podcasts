//
//  Episode.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-12.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let author: String
    let pubDate: Date
    let description: String
    var imageUrl: String?
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
    
} // Episode
