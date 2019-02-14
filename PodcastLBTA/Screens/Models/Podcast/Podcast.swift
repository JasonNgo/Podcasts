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
