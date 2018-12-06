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
//  EpisodesTableViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesTableViewController: UITableViewController {
  
  var episodes: [Episode] = []
  
  var podcast: Podcast? {
    didSet {
      navigationItem.title = podcast?.trackName
      fetchPodcastEpisodes()
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupEpisodesTableView()
    setupEpisodesNavigationBarButtons()
  }
  
  // MARK: - Setup
  
  fileprivate func setupEpisodesTableView() {
    let episodeCellNib = EpisodeCell.initFromNib()
    tableView.register(episodeCellNib, forCellReuseIdentifier: EpisodeCell.reuseIdentifier)
    tableView.tableFooterView = UIView()
  }
  
  fileprivate func setupEpisodesNavigationBarButtons() {
    let savedPodcasts = UserDefaults.standard.savedPodcasts()
    
    let podcastHasBeenFavourited = savedPodcasts.index {
      $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName
    }
    
    if podcastHasBeenFavourited != nil {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
    } else {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(handleSaveFavourites))
    }
  }
  
  // MARK: - Selectors
  
  @objc private func handleSaveFavourites() {
    print("Favourite pressed")
    guard let podcast = self.podcast else { return }
    
    var savedPodcasts = UserDefaults.standard.savedPodcasts()
    savedPodcasts.append(podcast)
    
    let savedPodcastsArchiveData = NSKeyedArchiver.archivedData(withRootObject: savedPodcasts)
    UserDefaults.standard.set(savedPodcastsArchiveData, forKey: UserDefaults.favouritePodcastsKey)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
    UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "new"
  }
  
  // MARK: - Helpers
  
  fileprivate func fetchPodcastEpisodes() {
    print("attempting to fetch episodes from RSS feed url: \(podcast?.feedUrl ?? "")")
    
    guard let unwrappedFeedUrl = podcast?.feedUrl else { return }
    APIService.shared.fetchEpisodesFrom(feedUrl: unwrappedFeedUrl) { (episodes) in
      self.episodes = episodes
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
}

// MARK: - UITableViewDelegate

extension EpisodesTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.reuseIdentifier, for: indexPath) as! EpisodeCell
    cell.episode = episodes[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return EpisodeCell.cellHeight
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episode = episodes[indexPath.row]
    UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: episodes)
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    activityIndicatorView.color = .darkGray
    activityIndicatorView.startAnimating()
    return activityIndicatorView
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return episodes.isEmpty ? 400 : 0
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
      let episode = self.episodes[indexPath.row]
      UserDefaults.standard.saveEpisode(episode: episode)
      APIService.shared.downloadEpisode(episode: episode)
    }
    
    return [downloadAction]
  }
  
}
