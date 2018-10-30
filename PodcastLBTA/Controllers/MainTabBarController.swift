//
//  MainTabBarController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // constraints
    fileprivate var maximizedTopAnchorConstraint: NSLayoutConstraint!
    fileprivate var minimizedTopAnchorConstraint: NSLayoutConstraint!
    fileprivate var bottomAnchorConstraint: NSLayoutConstraint!
    
    // floating player
    let playerDetailView = PlayerDetailView.initFromNib()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainTabBarControllerStyle()
        setupMainTabBarControllers()
        setupPlayerDetailView()
    }
    
    // MARK: - Floating Player
    func maximizePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        if episode != nil {
            playerDetailView.episode = episode
        }
        
        playerDetailView.playlistEpisodes = playlistEpisodes
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailView.maximizedStackView.alpha = 1
            self.playerDetailView.minimizedPlayerView.alpha = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func minimizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.tabBar.transform = .identity
            self.playerDetailView.maximizedStackView.alpha = 0
            self.playerDetailView.minimizedPlayerView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
} // MainTabBarController

// MARK: - Setup Functions
fileprivate extension MainTabBarController {
    
    func setupMainTabBarControllerStyle() {
        view.backgroundColor = .white
        tabBar.tintColor = .purple
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    func setupMainTabBarControllers() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        let favouritesCollectionView = FavouritesCollectionViewController(collectionViewLayout: collectionViewLayout)
        
        viewControllers = [
            createNavigationController(for: PodcastsTableViewController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            createNavigationController(for: favouritesCollectionView, title: "Favourites", image: #imageLiteral(resourceName: "favourite")),
            createNavigationController(for: DownloadsTableViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    func setupPlayerDetailView() {
        print("setting up PlayerDetailView")
        
        playerDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(playerDetailView, belowSubview: tabBar)
        
        // set constraint values
        bottomAnchorConstraint = playerDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        // activate constraints
        NSLayoutConstraint.activate([
            playerDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomAnchorConstraint,
            maximizedTopAnchorConstraint
        ])
    }
    
} // extension MainTabBarController - Setup

// MARK: Helper Functions
fileprivate extension MainTabBarController {
    
    func createNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        return navController
    }
    
} // extension MainTabBarController - Helpers
