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
//  APIService.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    private init() {}
    static let shared = APIService()
    
    struct PodcastsSearchResult: Decodable {
        var resultCount: Int?
        var results: [Podcast]?
    }
    
    let baseiTunesSearchUrl = "https://itunes.apple.com/search"
    
    func fetchPodcastsWith(searchText: String, completionHandler: @escaping ([Podcast]) -> Void) {
        print("searching for podcasts...")
        
        let parameters = ["term": searchText, "media": "podcast"]
        Alamofire.request(baseiTunesSearchUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("There was an error fetching list of podcasts", err)
                return
            }
            
            guard let data = dataResponse.data else { return }
            
            do {
                let searchResult = try JSONDecoder().decode(PodcastsSearchResult.self, from: data)
                guard let searchResultPodcasts = searchResult.results else { return }
                completionHandler(searchResultPodcasts)
            } catch let err {
                print("There was an error attempting to decode searchResult:", err)
            }
        }
    }
    
    func fetchEpisodesFrom(feedUrl: String, completionHandler: @escaping ([Episode]) -> Void) {
        guard let url = URL(string: feedUrl.toSecureHTTPS()) else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            let parser = FeedParser(URL: url)
            parser.parseAsync { (result) in
                guard let feed = result.rssFeed, result.isSuccess else {
                    print("There was an error attempting to parse the RSS feed: \(result.error?.description ?? "")")
                    return
                }
                
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            }
        }
    }
    
    func downloadEpisode(episode: Episode) {
        print("Attempting to download episode with streamUrl: \(episode.streamUrl)")
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            let userInfo: [String : Any] = [
                "title": episode.title,
                "author": episode.author,
                "progress": progress.fractionCompleted
            ]
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: userInfo)
        }.response { (response) in
            guard let fileUrl = response.destinationURL?.absoluteString else { return }
            
            var downloadedEpisodes = UserDefaults.standard.savedEpisodes()
            guard let index = downloadedEpisodes.index(of: episode) else { return }
            downloadedEpisodes[index].fileUrl = fileUrl
            
            let userInfo: [String : Any] = [
                "title": episode.title,
                "author": episode.author,
                "fileUrl": fileUrl
            ]
            
            NotificationCenter.default.post(name: .downloadComplete, object: nil, userInfo: userInfo)
            
            do {
                let data = try JSONEncoder().encode(downloadedEpisodes)
                UserDefaults.standard.set(data, forKey: UserDefaults.savedEpisodesKey)
            } catch let error {
                print("There was an error attempting to save list of episodes to UserDefaults", error)
            }
        }
    }
    
}
