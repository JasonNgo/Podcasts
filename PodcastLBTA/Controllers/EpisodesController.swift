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
    
    fileprivate let cellId = "episodeCell"
    
    var episodes = [Episode]()
    
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBarButtons()
    }
    
    // MARK: - Setup
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    fileprivate func setupNavigationBarButtons() {
        
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        
        let podcastHasBeenFavourited = savedPodcasts.index {
            return $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName
        }
        
        if podcastHasBeenFavourited != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(handleSaveFavourites))
        }
    }
    
    @objc func handleSaveFavourites() {
        print("Favourite pressed")
        
        guard let podcast = self.podcast else { return }
        
        var savedPodcasts = UserDefaults.standard.savedPodcasts()
        savedPodcasts.append(podcast)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: savedPodcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favouritePodcastsKey)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "new"
    }

    // MARK: Helper functions
    
    fileprivate func fetchEpisodes() {
        print("attempting to fetch episodes from RSS feed url: \(podcast?.feedUrl ?? "")")
        
        guard let unwrappedFeedUrl = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodesFrom(feedUrl: unwrappedFeedUrl) { (episodes) in
            self.episodes = episodes
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    } // fetchEpisodes

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: episodes)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 400 : 0
    }
    
} // EpisodesController
