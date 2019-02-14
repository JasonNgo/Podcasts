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
  
  var savedEpisodes = UserDefaults.standard.savedEpisodes()
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    savedEpisodes = UserDefaults.standard.savedEpisodes()
    tableView?.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDownloadsTableView()
    setupDownloadsTableViewObservers()
  }
  
  // MARK: - Setup
  
  fileprivate func setupDownloadsTableView() {
    let episodeCellNib = EpisodeCell.initFromNib()
    tableView.register(episodeCellNib, forCellReuseIdentifier: EpisodeCell.reuseIdentifier)
    tableView.tableFooterView = UIView()
  }
  
  fileprivate func setupDownloadsTableViewObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
  }
  
  // MARK: - Selector Functions
  
  @objc func handleDownloadProgress(notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let episodeTitle = userInfo["title"] as? String,
      let episodeAuthor = userInfo["author"] as? String,
      let downloadProgress = userInfo["progress"] as? Double,
      let index = savedEpisodes.index(where: { $0.title == episodeTitle && $0.author == episodeAuthor }),
      let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else {
        return
    }
    
    cell.downloadProgressLabel.isHidden = false
    cell.downloadProgressLabel.text = "\(Int(downloadProgress * 100))%"
  }
  
  @objc func handleDownloadComplete(notification: Notification) {
    guard
      let userInfo = notification.userInfo,
      let episodeTitle = userInfo["title"] as? String,
      let episodeAuthor = userInfo["author"] as? String,
      let fileUrl = userInfo["fileUrl"] as? String,
      let index = savedEpisodes.index(where: { $0.title == episodeTitle && $0.author == episodeAuthor }),
      let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else {
        return
    }
    
    cell.downloadProgressLabel.isHidden = true
    savedEpisodes[index].fileUrl = fileUrl
  }
  
  // MARK: - Helpers
  
  fileprivate func displayDownloadErrorMessage(for episode: Episode) {
    let alertController = UIAlertController(
      title: "Could not find fileUrl",
      message: "There was an error downloading the episode would you like to redownload the episode?",
      preferredStyle: .actionSheet
    )
    
    let downloadAction = UIAlertAction(title: "Download", style: .default) { (_) in
      APIService.shared.downloadEpisode(episode: episode)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alertController.addAction(downloadAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
}

// MARK: - UITableViewDelegate

extension DownloadsTableViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return savedEpisodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.reuseIdentifier, for: indexPath) as! EpisodeCell
    cell.episode = savedEpisodes[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return EpisodeCell.cellHeight
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
      let deletedEpisode = self.savedEpisodes.remove(at: indexPath.row)
      UserDefaults.standard.removeEpisode(episode: deletedEpisode)
      self.tableView?.reloadData()
    }
    
    return [deleteAction]
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episode = savedEpisodes[indexPath.row]
    
    guard let _ = episode.fileUrl else {
      displayDownloadErrorMessage(for: episode)
      return
    }
    
    UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: savedEpisodes)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let noResultsLabel = UILabel()
    noResultsLabel.text = "No results. Please download a podcast"
    noResultsLabel.textAlignment = .center
    noResultsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    return noResultsLabel
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return savedEpisodes.count > 0 ? 0 : 250
  }
  
}
