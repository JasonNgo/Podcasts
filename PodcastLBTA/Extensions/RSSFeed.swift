//
//  RSSFeed.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-13.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation
import FeedKit

extension RSSFeed {
    func toEpisodes() -> [Episode] {
        let podcastImageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]()
        
        items?.forEach({ (feedItem) in
            var episodeToAppend = Episode(feedItem: feedItem)
            
            if episodeToAppend.imageUrl == nil {
                episodeToAppend.imageUrl = podcastImageUrl
            }
            
            episodes.append(episodeToAppend)
        }) // forEach
        
        return episodes
    } // toEpisodes
    
} // Extension RSSFeed
