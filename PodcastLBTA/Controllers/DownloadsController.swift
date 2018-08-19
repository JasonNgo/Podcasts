//
//  DownloadsController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-17.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "cellEpisodeId"
    var savedEpisodes = UserDefaults.standard.savedEpisodes()
    
    // MARK: - Lifecycle Functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedEpisodes = UserDefaults.standard.savedEpisodes()
        tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObservers()
    }
    
    // MARK: - Setup Functions
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    // MARK: - Selector Functions
    
    @objc func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let episodeTitle = userInfo["title"] as? String else { return }
        guard let episodeAuthor = userInfo["author"] as? String else { return }
        guard let downloadProgress = userInfo["progress"] as? Double else { return }
        
        guard let index = savedEpisodes.index(where: { $0.title == episodeTitle && $0.author == episodeAuthor }) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        
        cell.downloadProgressLabel.isHidden = false
        cell.downloadProgressLabel.text = "\(Int(downloadProgress * 100))%"
    }
    
    @objc func handleDownloadComplete(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let episodeTitle = userInfo["title"] as? String else { return }
        guard let episodeAuthor = userInfo["author"] as? String else { return }
        guard let fileUrl = userInfo["fileUrl"] as? String else { return }
        
        guard let index = savedEpisodes.index(where: { $0.title == episodeTitle && $0.author == episodeAuthor }) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        
        cell.downloadProgressLabel.isHidden = true
        savedEpisodes[index].fileUrl = fileUrl
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = self.savedEpisodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            let removedEpisode = self.savedEpisodes.remove(at: indexPath.row)
            UserDefaults.standard.removeEpisode(episode: removedEpisode)
            self.tableView?.reloadData()
        }
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.savedEpisodes[indexPath.row]
        
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.savedEpisodes)
        } else {
            let alertController = UIAlertController(title: "Could not find fileUrl", message: "There was an error downloading the episode would you like to redownload the episode?", preferredStyle: .actionSheet)
            
            let downloadAction = UIAlertAction(title: "Download", style: .default) { (_) in
                APIService.shared.downloadEpisode(episode: episode)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                print("Cancel action pressed")
            }
            
            alertController.addAction(downloadAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true)
        }
    }
    
}
