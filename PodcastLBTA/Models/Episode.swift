//
//  Episode.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-12.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Equatable, Codable {
    let title: String
    let author: String
    let pubDate: Date
    let description: String
    
    var imageUrl: String?
    let streamUrl: String
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
    }
    
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        return lhs.title == rhs.title && lhs.author == rhs.author
    }
    
} // Episode
