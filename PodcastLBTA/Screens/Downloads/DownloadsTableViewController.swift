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
//  DownloadsTableViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-17.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class DownloadsTableViewController: UITableViewController {
    
    // MARK: - Configurations
    private let cellHeight: CGFloat = 132
    
    // MARK: - Dependencies
    private let dataSource: DownloadsTableViewDataSource
    
    init(dataSource: DownloadsTableViewDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchSavedEpisodes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDownloadsTableView()
        setupDownloadsTableViewObservers()
        fetchSavedEpisodes()
    }
    
    // MARK: - Setup
    
    private func setupDownloadsTableView() {
        let episodeCellNib = UINib(nibName: dataSource.reuseId, bundle: nil)
        tableView.register(episodeCellNib, forCellReuseIdentifier: dataSource.reuseId)
        tableView.dataSource = self.dataSource
        tableView.tableFooterView = UIView()
    }
    
    private func setupDownloadsTableViewObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    private func fetchSavedEpisodes() {
        dataSource.fetchSavedEpisodes { error in
            if let _ = error {
                return
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Selector Functions
    
    @objc private func handleDownloadProgress(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let episodeTitle = userInfo["title"] as? String,
            let episodeAuthor = userInfo["author"] as? String,
            let downloadProgress = userInfo["progress"] as? Double,
            let index = dataSource.episodes.index(where: { $0.title == episodeTitle && $0.author == episodeAuthor }),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
        else {
            return
        }
        
        cell.setDownloadLabel(downloadProgress: downloadProgress)
    }
    
    @objc private func handleDownloadComplete(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let episodeTitle = userInfo["title"] as? String,
            let episodeAuthor = userInfo["author"] as? String,
            let fileUrl = userInfo["fileUrl"] as? String,
            let index = dataSource.episodes.index(where: { $0.title == episodeTitle && $0.author == episodeAuthor }),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell
        else {
            return
        }
        
        cell.setDownloadLabel(downloadProgress: 100)
        dataSource.saveDownloadUrl(for: index, fileUrl: fileUrl)
    }
    
    // MARK: - Helpers
    
    private func displayDownloadErrorMessage(for episode: Episode) {
        let alertController = UIAlertController(
            title: "Could not find fileUrl",
            message: "There was an error downloading the episode would you like to redownload the episode?",
            preferredStyle: .actionSheet
        )
        
        let downloadAction = UIAlertAction(title: "Download", style: .default) { (_) in
            self.dataSource.downloadEpisode(episode: episode)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(downloadAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Required
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate

extension DownloadsTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            self.dataSource.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let episode = dataSource.item(at: indexPath.row) else { return }
        
        guard let _ = episode.fileUrl else {
            displayDownloadErrorMessage(for: episode)
            return
        }
        
        let userInfo: [String: Any] = [
            "episode": episode,
            "playlistEpisodes": dataSource.episodes
        ]
        
        NotificationCenter.default.post(name: .maximizePlayer, object: nil, userInfo: userInfo)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let noResultsLabel = UILabel()
        noResultsLabel.text = "No results. Please download a podcast"
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return noResultsLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.isEmpty ? 450 : 0
    }
}
