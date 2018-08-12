//
//  EpisodesController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = [Episode]()
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            
            fetchEpisodes()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    // MARK: Setup
    
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    // MARK: Helper functions
    
    fileprivate func fetchEpisodes() {
        print("attempting to fetch episodes from RSS feed url: \(podcast?.feedUrl ?? "")")
        
        guard let unwrappedFeedUrl = podcast?.feedUrl else { return }
        let secureFeedUrl = unwrappedFeedUrl.contains("https") ? unwrappedFeedUrl ? unwrappedFeedUrl.replacingOccurrences(of: "http", with: "https")
        
        guard let url = URL(string: secureFeedUrl) else { return }
        let parser = FeedParser(URL: url)
        
        parser.parseAsync { (result) in
            
            guard let feed = result.rssFeed, result.isSuccess else {
                print("There was an error attempting to parse the RSS feed.", result.error)
                return
            }
            
            var tempEpisodes = [Episode]()
            
            feed.items?.forEach({ (feedItem) in
                guard let episodeTitle = feedItem.title else { return }
                
                let episodeToAppend = Episode(title: episodeTitle)
                tempEpisodes.append(episodeToAppend)
                
                self.episodes = tempEpisodes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }) // forEach
        } // parseAsync
    } // fetchEpisodes

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let episode = episodes[indexPath.row]
        
        cell.textLabel?.text = episode.title
        
        return cell
    }
    
} // EpisodesController
