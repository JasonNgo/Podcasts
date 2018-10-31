//
//  PodcastsTableViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import Alamofire

class SearchTableViewController: UITableViewController {
    
    // constants
    fileprivate let podcastCellId = "podcastCell"
    fileprivate let podcastCellRowHeight: CGFloat = 116
    
    fileprivate var searchDelayTimer: Timer?
    
    let podcastsSearchController = UISearchController(searchResultsController: nil)
    
    var podcasts: [Podcast] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPodcastSearchController()
        setupPodcastsTableView()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let noResultsLabel = UILabel()
        noResultsLabel.text = "No results. Please enter a search term"
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return noResultsLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return podcastCellRowHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: podcastCellId, for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesViewController = EpisodesTableViewController()
        episodesViewController.podcast = podcasts[indexPath.row]
        navigationController?.pushViewController(episodesViewController, animated: true)
    }
    
} // PodcastsTableViewController

// MARK: - Setup Functions

fileprivate extension SearchTableViewController {
    
    func setupPodcastSearchController() {
        self.definesPresentationContext = true
        navigationItem.searchController = podcastsSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        podcastsSearchController.dimsBackgroundDuringPresentation = false
        podcastsSearchController.searchBar.delegate = self
    }
    
    func setupPodcastsTableView() {
        let podcastCellNib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(podcastCellNib, forCellReuseIdentifier: podcastCellId)
        tableView.tableFooterView = UIView()
    }
    
}

// MARK: - UISearchBarDelegate
extension SearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        searchDelayTimer?.invalidate()
        searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            APIService.shared.fetchPodcastsWith(searchText: searchText) { (podcasts) in
                self.podcasts = podcasts
                self.tableView.reloadData()
            }
        })
    }
}
