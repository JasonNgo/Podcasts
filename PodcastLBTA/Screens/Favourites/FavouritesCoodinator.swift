//
//  FavouritesCoodinator.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class FavouritesCoordinator: Coordinator {
    // MARK: - Dependencies
    private let dataSource: FavouritesCollectionViewDataSource
    
    let navigationController: UINavigationController
    private var favouritesController: FavouritesCollectionViewController?
    
    // MARK: - Child Coordinators
    private var episodesCoordinator: EpisodesCoordinator?
    
    init(navigationController: UINavigationController, dataSource: FavouritesCollectionViewDataSource) {
        self.navigationController = navigationController
        self.dataSource = dataSource
        super.init()
        
        setupNavigationControllerStyling()
    }
    
    private func setupNavigationControllerStyling() {
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    override func start() {
        let favouritesController = FavouritesCollectionViewController(dataSource: dataSource)
        favouritesController.delegate = self
        favouritesController.title = "Favourites"
        favouritesController.tabBarItem.title = "Favourites"
        favouritesController.tabBarItem.image = #imageLiteral(resourceName: "favourite").withRenderingMode(.alwaysOriginal)
        navigationController.pushViewController(favouritesController, animated: false)
        self.favouritesController = favouritesController
    }
}

extension FavouritesCoordinator: FavouritesCollectionViewDelegate {
    func favouritesCollectionViewDidSelect(podcast: Podcast) {
        let episodesCoordinator = EpisodesCoordinator(navigationController: navigationController, podcast: podcast)
        episodesCoordinator.start()
        episodesCoordinator.stop = { [weak self] in
            self?.episodesCoordinator = nil
        }
        self.episodesCoordinator = episodesCoordinator
    }
}
