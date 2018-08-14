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
    
    // singleton
    static let shared = APIService()
    
    // base url
    let baseiTunesSearchUrl = "https://itunes.apple.com/search"
    
    struct SearchResult: Decodable {
        var resultCount: Int?
        var results: [Podcast]?
    }
    
    func fetchPodcastsWith(searchText: String, completionHandler: @escaping ([Podcast]) -> Void) {
        print("searching for podcasts...")
        
        let parameters = [
            "term": searchText,
            "media": "podcast"
        ]
        
        Alamofire.request(baseiTunesSearchUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("There was an error fetching list of podcasts", err)
                return
            }
            
            guard let data = dataResponse.data else { return }
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                guard let searchResultPodcasts = searchResult.results else { return }
                completionHandler(searchResultPodcasts)
            } catch let err {
                print("There was an error attempting to decode searchResult:", err)
            }
        } // request
        
    } // fetchPodcastsWith(searchText:completionHandler:)
    
    func fetchEpisodesFrom(feedUrl: String, completionHandler: @escaping ([Episode]) -> Void) {
        print("searching for episodes...")
        
        guard let url = URL(string: feedUrl.toSecureHTTPS()) else { return }
        
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            
            parser.parseAsync { (result) in
                guard let feed = result.rssFeed, result.isSuccess else {
                    print("There was an error attempting to parse the RSS feed: \(result.error?.description ?? "")")
                    return
                }
                
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            } // parseAsync
        }
        
    } // fetchEpisodesFrom(feedUrl:completionHandler:)
    
}
