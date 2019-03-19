//
//  DownloadsTableViewDataSource.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-15.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class DownloadsTableViewDataSource: NSObject {
    private(set) var episodes: [Episode] = []
    private(set) var reuseId = "EpisodeCell"
    
    var isEmpty: Bool {
        return episodes.isEmpty
    }
    
    func item(at index: Int) -> Episode? {
        guard !isEmpty else {
            return nil
        }
        
        return episodes[index]
    }
    
    @discardableResult
    func remove(at index: Int) -> Episode {
        guard !isEmpty else {
            fatalError("Attempting to remove but array is empty")
        }
        
        let deletedEpisode = episodes.remove(at: index)
        UserDefaults.standard.removeEpisode(episode: deletedEpisode)
        
        return deletedEpisode
    }
    
    func fetchSavedEpisodes(completion: @escaping (Error?) -> Void) {
        let newEpisodes = UserDefaults.standard.savedEpisodes()
        
        if newEpisodes != episodes {
            self.episodes = newEpisodes
            completion(nil)
        }
    }
    
    func downloadEpisode(episode: Episode) {
        APIService.shared.downloadEpisode(episode: episode)
    }
    
    func saveDownloadUrl(for index: Int, fileUrl: String) {
        var episode = episodes[index]
        episode.fileUrl = fileUrl
    }
}

extension DownloadsTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? EpisodeCell else {
            fatalError("Unable to dequeue cell")
        }
        
        let episode = episodes[indexPath.row]
        let viewModel = EpisodeCellViewModel(episode: episode)
        cell.configureCell(using: viewModel)
        
        return cell
    }
}


