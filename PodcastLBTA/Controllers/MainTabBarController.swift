//
//  MainTabBarController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    let playerDetailView = PlayerDetailView.initFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        setupControllerStyles()
        setupTabBarControllers()
        setupPlayerDetailView()
    }
    
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
            self.view.layoutIfNeeded()
            
            self.playerDetailView.maximizedStackView.alpha = 1
            self.playerDetailView.minimizedPlayerView.alpha = 0
        })
    }
    
    func minimizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.tabBar.transform = .identity
            self.view.layoutIfNeeded()
            
            self.playerDetailView.maximizedStackView.alpha = 0
            self.playerDetailView.minimizedPlayerView.alpha = 1
        })
    }
    
    // MARK: - Setup Functions
    
    fileprivate func setupControllerStyles() {
        view.backgroundColor = .white
        tabBar.tintColor = .purple
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    fileprivate func setupTabBarControllers() {
        let flowLayout = UICollectionViewFlowLayout()
        let favouritesCollectionView = FavouritesController(collectionViewLayout: flowLayout)
        
        viewControllers = [
            createNavigationController(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            createNavigationController(for: favouritesCollectionView, title: "Favourites", image: #imageLiteral(resourceName: "favourite")),
            createNavigationController(for: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    fileprivate func setupPlayerDetailView() {
        print("Setting up PlayerDetailView")
        
        playerDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(playerDetailView, belowSubview: tabBar)
        
        playerDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        bottomAnchorConstraint = playerDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        maximizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        
        minimizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
    }
    
    // MARK: - Helper Functions
    
    fileprivate func createNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        rootViewController.navigationItem.title = title
        
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        
        return navController
    }
    
} // MainTabBarController
