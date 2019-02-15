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
import JGProgressHUD

enum SearchTableViewState {
    case loading
    case empty
    case populated
    case error(Error)
}

protocol SearchTableViewDelegate: AnyObject {
    func searchTableViewDidSelect(podcast: Podcast)
}

// TODO: Use state var to update background view of tableview

class SearchTableViewController: UITableViewController, Deinitcallable {
    // MARK: - Dependencies
    private let dataSource: SearchTableViewDataSource

    // MARK: - Configurations
    private let cellHeight: CGFloat = 116
    private let noResultsText = "No results. Please enter a search term"

    private let podcastsSearchController = UISearchController(searchResultsController: nil)
    
    private lazy var progressHUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Searching for podcasts"
        return hud
    }()
    
    weak var delegate: SearchTableViewDelegate?
    
    private var state: SearchTableViewState = .empty {
        didSet {
            switch state {
            case .loading:
                self.progressHUD.show(in: self.view, animated: true)
            case .populated:
                self.progressHUD.dismiss()
            case .empty:
                self.progressHUD.dismiss()
            default:
                break
            }
        }
    }
    
    // MARK: - Life Cycle
    var onDeinit: (() -> Void)?
    
    deinit {
        onDeinit?()
    }
    
    init(dataSource: SearchTableViewDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPodcastSearchController()
        setupPodcastsTableView()
    }
    
    // MARK: - Setup
    
    private func setupPodcastSearchController() {
        self.definesPresentationContext = true
        navigationItem.searchController = podcastsSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        podcastsSearchController.dimsBackgroundDuringPresentation = false
        podcastsSearchController.searchBar.delegate = self
    }
    
    private func setupPodcastsTableView() {
        let podcastCellNib = UINib(nibName: dataSource.reuseId, bundle: nil)
        tableView.register(podcastCellNib, forCellReuseIdentifier: dataSource.reuseId)
        tableView.dataSource = self.dataSource
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate

extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let noResultsLabel = UILabel()
        noResultsLabel.text = noResultsText
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return noResultsLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.isEmpty ? 450 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let podcast = dataSource.item(at: indexPath.row) else { return }
        delegate?.searchTableViewDidSelect(podcast: podcast)
    }
}

// MARK: - UISearchBarDelegate

extension SearchTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        state = .loading
        dataSource.searchItems(with: searchText) { (error) in
            if let _ = error { return }
            
            self.state = .populated
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
