//
//  EpisodesTableViewDataSource.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class EpisodesTableViewDataSource: NSObject {
    
    private(set) var episodes: [Episode] = []
    private(set) var reuseId = "EpisodeCell"
    private(set) var podcast: Podcast
    
    var isEmpty: Bool {
        return episodes.isEmpty
    }
    
    var title: String? {
        return podcast.trackName
    }
    
    init(podcast: Podcast) {
        self.podcast = podcast
        super.init()
    }
    
    func item(at index: Int) -> Episode? {
        guard !episodes.isEmpty else {
            return nil
        }
        
        return episodes[index]
    }
    
    func fetchEpisodes(completion: @escaping (Error?) -> Void) {
        print("attempting to fetch episodes from RSS feed url: \(podcast.feedUrl ?? "")")

        guard let feedUrl = podcast.feedUrl else {
            // TODO: completion with error
            return
        }
        
        APIService.shared.fetchEpisodesFrom(feedUrl: feedUrl) { [weak self] episodes in
            self?.episodes = episodes
            completion(nil)
        }
    }
}

extension EpisodesTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? EpisodeCell else {
            fatalError("Unable to dequeue EpisodeCell")
        }
        
        let episode = episodes[indexPath.row]
        let viewModel = EpisodeCellViewModel(episode: episode)
        cell.configureCell(using: viewModel)
        
        return cell
    }
}
