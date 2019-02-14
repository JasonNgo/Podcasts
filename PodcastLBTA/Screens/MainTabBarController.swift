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
//  MainTabBarController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-11.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Views
    private let playerDetailView = PlayerDetailView.initFromNib()
    
    fileprivate var maximizedTopAnchorConstraint: NSLayoutConstraint!
    fileprivate var minimizedTopAnchorConstraint: NSLayoutConstraint!
    fileprivate var bottomAnchorConstraint: NSLayoutConstraint!
    
    private let searchDataSource: SearchTableViewDataSource
    private var searchCoordinator: SearchCoordinator?
    
    // MARK: - Initializer
    
    init() {
        self.searchDataSource = SearchTableViewDataSource()
        self.searchCoordinator = SearchCoordinator(navigationController: UINavigationController(), dataSource: searchDataSource)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCoordinator?.start()
        
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
        
        let maximizePlayerDetailsClosure = {
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailView.maximizedStackView.alpha = 1
            self.playerDetailView.minimizedPlayerView.alpha = 0
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                maximizePlayerDetailsClosure()
        })
    }
    
    func minimizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        let minimizePlayerDetailClosure = {
            self.tabBar.transform = .identity
            self.playerDetailView.maximizedStackView.alpha = 0
            self.playerDetailView.minimizedPlayerView.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                minimizePlayerDetailClosure()
        })
    }
    
    // MARK: - Setup
    
    fileprivate func setupMainTabBarControllerStyle() {
        view.backgroundColor = .white
        tabBar.tintColor = .purple
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    fileprivate func setupMainTabBarControllers() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        guard
            let searchCoordinatorNavController = searchCoordinator?.navigationController
        else {
            return
        }
        
        let favouritesCollectionView = FavouritesCollectionViewController(collectionViewLayout: collectionViewLayout)
        
        viewControllers = [
            searchCoordinatorNavController,
            createNavigationController(for: favouritesCollectionView, title: "Favourites", image: #imageLiteral(resourceName: "favourite")),
            createNavigationController(for: DownloadsTableViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    fileprivate func setupPlayerDetailView() {
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
    
    // MARK: - Helpers
    
    fileprivate func createNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        return navController
    }
    
}
