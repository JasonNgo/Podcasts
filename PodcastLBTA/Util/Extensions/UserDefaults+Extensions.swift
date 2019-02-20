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
        let filteredPodcasts = podcasts.filter { $0.trackName != podcast.trackName && $0.artistName != podcast.artistName }
        guard filteredPodcasts.count != podcasts.count else { return }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favouritePodcastsKey)
    }
    
    func savedEpisodes() -> [Episode] {
        guard let savedEpisodesData = UserDefaults.standard.data(forKey: UserDefaults.savedEpisodesKey) else { return [] }
        
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: savedEpisodesData)
            return episodes
        } catch let error {
            print("There was an error attempting to decode saved episodes object:", error)
            return []
        }
    }
    
    func saveEpisode(episode: Episode) {
        var savedEpisodes = self.savedEpisodes()
        let episodeHasBeenDownloaded = savedEpisodes.index { $0.title == episode.title && $0.author == episode.author }
        guard episodeHasBeenDownloaded == nil else { return }
        
        do {
            savedEpisodes.append(episode)
            let data = try JSONEncoder().encode(savedEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.savedEpisodesKey)
        } catch let error {
            print("There was an error attempting to convert Episode to JSON format", error)
        }
    }
    
    func removeEpisode(episode: Episode) {
        let savedEpisodes = self.savedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { $0.title != episode.title && $0.pubDate != episode.pubDate }
        guard filteredEpisodes.count != savedEpisodes.count else { return }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.savedEpisodesKey)
        } catch let error {
            print("There was an error attempting to encode saved episodes:", error)
        }
    }
}
