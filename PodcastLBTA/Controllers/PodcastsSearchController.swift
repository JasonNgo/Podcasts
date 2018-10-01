//
//  PodcastsSearchController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController {
    
    fileprivate let cellId = "podcastCell"
    fileprivate var timer: Timer?
    fileprivate let rowHeight: CGFloat = 116
    
    var podcasts = [Podcast]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        setupTableView()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No results. Please enter a search term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        episodesController.podcast = podcasts[indexPath.row]
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
} // PodcastsSearchController

// MARK: - Setup Functions

private extension PodcastsSearchController {
    func setupSearchController() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
}

// MARK: - UISearchBarDelegate

extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            APIService.shared.fetchPodcastsWith(searchText: searchText) { (podcasts) in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }
}
