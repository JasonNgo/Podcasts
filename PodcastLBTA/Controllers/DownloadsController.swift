//
//  DownloadsController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-17.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    var savedEpisodes = UserDefaults.standard.savedEpisodes()
    
    fileprivate let cellId = "cellEpisodeId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedEpisodes = UserDefaults.standard.savedEpisodes()
        tableView?.reloadData()
    }
    
    // MARK: - Setup Functions
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
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
    
}
