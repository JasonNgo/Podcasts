//
//  SearchCoordinator.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class SearchCoordinator: Coordinator {
    // MARK: - Dependencies
    private let dataSource: SearchTableViewDataSource
    
    let navigationController: UINavigationController
//    private var episodeCoordinator: EpisodeCoordinator?
    
    init(navigationController: UINavigationController, dataSource: SearchTableViewDataSource) {
        self.dataSource = dataSource
        self.navigationController = navigationController
        super.init()
        
        setupNavigationControllerStyling()
    }
    
    private func setupNavigationControllerStyling() {
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    override func start() {
        let searchController = SearchTableViewController(dataSource: dataSource)
        searchController.delegate = self
        searchController.title = "Search"
        searchController.tabBarItem.title = "Search"
        searchController.tabBarItem.image = #imageLiteral(resourceName: "search").withRenderingMode(.alwaysOriginal)
        setDeallocallable(with: searchController)
        navigationController.pushViewController(searchController, animated: false)
    }
}

extension SearchCoordinator: SearchTableViewDelegate {
    func searchTableViewDidSelect(item: Podcast) {
        // print("))
    }
}
