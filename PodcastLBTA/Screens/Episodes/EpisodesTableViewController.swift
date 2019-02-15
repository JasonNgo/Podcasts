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

class EpisodesTableViewController: UITableViewController, Deinitcallable {
    // MARK: - Dependencies
    private let dataSource: EpisodesTableViewDataSource
    
    // MARK: - Configurations
    private let cellHeight: CGFloat = 132
    
    // MARK: - Lifecycle
    
    var onDeinit: (() -> Void)?
    
    deinit {
        onDeinit?()
    }
    
    init(dataSource: EpisodesTableViewDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEpisodesTableView()
        setupEpisodesNavigationBarButtons()
        fetchEpisodes()
    }
    
    // MARK: - Setup
    
    private func setupEpisodesTableView() {
        tableView.dataSource = self.dataSource
        let episodeCellNib = UINib(nibName: dataSource.reuseId, bundle: nil)
        tableView.register(episodeCellNib, forCellReuseIdentifier: dataSource.reuseId)
        tableView.tableFooterView = UIView()
    }
    
    private func setupEpisodesNavigationBarButtons() {
        navigationItem.title = dataSource.title
        let savedPodcasts = UserDefaults.standard.savedPodcasts()

        let podcastHasBeenFavourited = savedPodcasts.index {
            return $0.trackName == dataSource.podcast.trackName &&
                   $0.artistName == dataSource.podcast.artistName
        }

        if podcastHasBeenFavourited != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(handleSaveFavourites))
        }
    }
    
    // MARK: - Selectors
    
    @objc private func handleSaveFavourites() {
        let podcast = dataSource.podcast

        var savedPodcasts = UserDefaults.standard.savedPodcasts()
        savedPodcasts.append(podcast)

        let savedPodcastsArchiveData = NSKeyedArchiver.archivedData(withRootObject: savedPodcasts)
        UserDefaults.standard.set(savedPodcastsArchiveData, forKey: UserDefaults.favouritePodcastsKey)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "new"
    }
    
    // MARK: - Helpers
    
    private func fetchEpisodes() {
        dataSource.fetchEpisodes { (error) in
            if let _ = error {
                // TODO: error state
                return
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate

extension EpisodesTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let episode = dataSource.item(at: indexPath.row) else { return }
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: dataSource.episodes)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataSource.isEmpty ? 400 : 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            guard let episode = self.dataSource.item(at: indexPath.row) else { return }
            UserDefaults.standard.saveEpisode(episode: episode)
            APIService.shared.downloadEpisode(episode: episode)
        }
        
        return [downloadAction]
    }
}
