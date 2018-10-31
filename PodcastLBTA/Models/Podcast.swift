//
//  Podcast.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    
    enum PodcastCodingKey: String {
        case title = "podcastCodingTitleKey"
        case artist = "podcastCodingArtistKey"
        case artworkUrl = "podcastCodingArtworkUrlKey"
        case feedUrl = "podcastCodingFeedUrlKey"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName ?? "", forKey: PodcastCodingKey.title.rawValue)
        aCoder.encode(artistName ?? "", forKey: PodcastCodingKey.artist.rawValue)
        aCoder.encode(artworkUrl600 ?? "", forKey: PodcastCodingKey.artworkUrl.rawValue)
        aCoder.encode(feedUrl ?? "", forKey: PodcastCodingKey.feedUrl.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: PodcastCodingKey.title.rawValue) as? String
        self.artistName = aDecoder.decodeObject(forKey: PodcastCodingKey.artist.rawValue) as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: PodcastCodingKey.artworkUrl.rawValue) as? String
        self.feedUrl = aDecoder.decodeObject(forKey: PodcastCodingKey.feedUrl.rawValue) as? String
    }
    
}
