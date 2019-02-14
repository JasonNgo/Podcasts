//
//  FavouritesCoodinator.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class FavouritesCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
        setupNavigationControllerStyling()
    }
    
    private func setupNavigationControllerStyling() {
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
//    override func start() {
//        let favouritesController = FavouritesCollectionViewController()
//        favouritesController.title = "Favourites"
//        favouritesController.tabBarItem.title = "Favourites"
//        favouritesController.tabBarItem.image = #imageLiteral(resourceName: "favourite").withRenderingMode(.alwaysOriginal)
//        setDeallocallable(with: favouritesController)
//        navigationController.pushViewController(favouritesController, animated: false)
//    }
}
