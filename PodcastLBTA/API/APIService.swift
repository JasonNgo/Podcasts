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

extension NSNotification.Name {
    static let downloadProgress =  NSNotification.Name("downloadProgress")
    static let downloadComplete =  NSNotification.Name("downloadComplete")
}

class APIService {
    
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
            
            // updateDownloadedEpisode with fileUrl
            var downloadedEpisodes = UserDefaults.standard.savedEpisodes()
            guard let index = downloadedEpisodes.index(of: episode) else { return }
            downloadedEpisodes[index].fileUrl = fileUrl
            
            let userInfo: [String : Any] = [
                "title": episode.title,
                "author": episode.author,
                "fileUrl": fileUrl
            ]
            
            NotificationCenter.default.post(name: .downloadComplete, object: nil, userInfo: userInfo)
            
            // update UserDefaults with new episode
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(downloadedEpisodes)
                UserDefaults.standard.set(data, forKey: UserDefaults.savedEpisodesKey)
            } catch let error {
                print("There was an error attempting to save list of episodes to UserDefaults", error)
            }
        }
    }
    
}
