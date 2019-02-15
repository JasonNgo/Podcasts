//
//  EpisodesCoordinator.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class EpisodesCoordinator: Coordinator {
    // MARK: - Dependencies
    private let dataSource: EpisodesTableViewDataSource
    
    let navigationController: UINavigationController
    private var episodesController: EpisodesTableViewController?
    
    init(navigationController: UINavigationController, podcast: Podcast) {
        self.dataSource = EpisodesTableViewDataSource(podcast: podcast)
        self.navigationController = navigationController
        super.init()
    }
    
    private func setupNavigationControllerStyling() {
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    override func start() {
        let episodesController = EpisodesTableViewController(dataSource: dataSource)
        setDeallocallable(with: episodesController)
        navigationController.pushViewController(episodesController, animated: true)
        self.episodesController = episodesController
    }
}
