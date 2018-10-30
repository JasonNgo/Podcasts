//
//  DownloadsTableViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-17.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class DownloadsTableViewController: UITableViewController {
    
    fileprivate let downloadsCellId = "downloadsCellId"
    fileprivate let downloadsCellRowHeight: CGFloat = 134
    
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
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: downloadsCellId, for: indexPath) as! EpisodeCell
        cell.episode = savedEpisodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return downloadsCellRowHeight
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
        let episode = self.savedEpisodes[indexPath.row]
        
        guard episode.fileUrl != nil else {
            displayDownloadErrorMessage(for: episode)
            return
        }
        
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.savedEpisodes)
    }
    
} // Downloads Controller

// MARK: - Setup Functions
private extension DownloadsTableViewController {
    
    func setupDownloadsTableView() {
        let episodeCellNib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(episodeCellNib, forCellReuseIdentifier: downloadsCellId)
    }
    
    func setupDownloadsTableViewObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
}

// MARK: - Selector Functions
private extension DownloadsTableViewController {
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
}

// MARK: - Helper Functions
fileprivate extension DownloadsTableViewController {
    func displayDownloadErrorMessage(for episode: Episode) {
        let alertController = UIAlertController(title: "Could not find fileUrl",
                                                message: "There was an error downloading the episode would you like to redownload the episode?",
                                                preferredStyle: .actionSheet)
        
        let downloadAction = UIAlertAction(title: "Download", style: .default) { (_) in
            APIService.shared.downloadEpisode(episode: episode)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(downloadAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
