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
//  PodcastsTableViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import Alamofire

class SearchTableViewController: UITableViewController {
  
  private var searchDelayTimer: Timer?
  private var podcasts: [Podcast] = []
  private let podcastsSearchController = UISearchController(searchResultsController: nil)
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupPodcastSearchController()
    setupPodcastsTableView()
  }
  
  // MARK: - Setup
  
  fileprivate func setupPodcastSearchController() {
    self.definesPresentationContext = true
    navigationItem.searchController = podcastsSearchController
    navigationItem.hidesSearchBarWhenScrolling = false
    podcastsSearchController.dimsBackgroundDuringPresentation = false
    podcastsSearchController.searchBar.delegate = self
  }
  
  fileprivate func setupPodcastsTableView() {
    let podcastCellNib = PodcastCell.initFromNib()
    tableView.register(podcastCellNib, forCellReuseIdentifier: PodcastCell.reuseIdentifier)
    tableView.tableFooterView = UIView()
  }
  
}

// MARK: - UITableViewDelegate

extension SearchTableViewController {
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let noResultsLabel = UILabel()
    noResultsLabel.text = "No results. Please enter a search term"
    noResultsLabel.textAlignment = .center
    noResultsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    return noResultsLabel
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return podcasts.count > 0 ? 0 : 250
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return PodcastCell.cellHeight
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.reuseIdentifier, for: indexPath) as! PodcastCell
    cell.podcast = podcasts[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episodesViewController = EpisodesTableViewController()
    episodesViewController.podcast = podcasts[indexPath.row]
    navigationController?.pushViewController(episodesViewController, animated: true)
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
