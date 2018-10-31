//
//  UserDefaults.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-16.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favouritePodcastsKey = "favouritePodcastsKey"
    static let savedEpisodesKey = "savedEpisodesKey"
    
    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favouritePodcastsKey) else { return [] }
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else { return [] }
        return savedPodcasts
    }
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter {
            return $0.trackName != podcast.trackName && $0.artistName != podcast.artistName
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favouritePodcastsKey)
    }
    
    func savedEpisodes() -> [Episode] {
        guard let savedEpisodesData = UserDefaults.standard.data(forKey: UserDefaults.savedEpisodesKey) else { return [] }
        
        let decoder = JSONDecoder()
        do {
            let episodes = try decoder.decode([Episode].self, from: savedEpisodesData)
            return episodes
        } catch let error {
            print("There was an error attempting to decode saved episodes object:", error)
            return []
        }
    }
    
    func saveEpisode(episode: Episode) {
        let encoder = JSONEncoder()
        var savedEpisodes = self.savedEpisodes()
        
        let episodeHasBeenDownloaded = savedEpisodes.index {
            return $0.title == episode.title && $0.author == episode.author
        }
        
        guard episodeHasBeenDownloaded == nil else { return }
        
        do {
            savedEpisodes.append(episode)
            let data = try encoder.encode(savedEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.savedEpisodesKey)
        } catch let error {
            print("There was an error attempting to convert Episode to JSON format", error)
        }
    }
    
    func removeEpisode(episode: Episode) {
        let savedEpisodes = self.savedEpisodes()
        let filteredEpisodes = savedEpisodes.filter {
            return $0.title != episode.title && $0.pubDate != episode.pubDate
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.savedEpisodesKey)
        } catch let error {
            print("There was an error attempting to encode saved episodes:", error)
        }
    }
    
} // Extension UserDefaults
