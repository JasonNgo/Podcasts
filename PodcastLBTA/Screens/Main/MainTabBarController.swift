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
    
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    // MARK: - Tab Bar Coordinators
    private let searchCoordinator: SearchCoordinator
    private let favouritesCoordinator: FavouritesCoordinator
    private let downloadsCoordinator: DownloadsCoordinator
    
    // MARK: - Data Sources
    private let searchDataSource: SearchTableViewDataSource
    private let favouritesDataSource: FavouritesCollectionViewDataSource
    private let downloadsDataSource: DownloadsTableViewDataSource
    
    // MARK: - Initializer
    
    init() {
        self.searchDataSource = SearchTableViewDataSource()
        self.favouritesDataSource = FavouritesCollectionViewDataSource()
        self.downloadsDataSource = DownloadsTableViewDataSource()
        
        self.searchCoordinator = SearchCoordinator(navigationController: UINavigationController(), dataSource: searchDataSource)
        self.favouritesCoordinator = FavouritesCoordinator(navigationController: UINavigationController(), dataSource: favouritesDataSource)
        self.downloadsCoordinator = DownloadsCoordinator(navigationController: UINavigationController(), dataSource: downloadsDataSource)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCoordinators()
        setupMainTabBarControllerStyle()
        setupMainTabBarControllers()
        setupPlayerDetailView()
    }
    
    // MARK: - Setup
    
    private func setupCoordinators() {
        searchCoordinator.start()
        favouritesCoordinator.start()
        downloadsCoordinator.start()
    }
    
    private func setupMainTabBarControllerStyle() {
        view.backgroundColor = .white
        tabBar.tintColor = .purple
    }
    
    private func setupMainTabBarControllers() {
        viewControllers = [
            searchCoordinator.navigationController,
            favouritesCoordinator.navigationController,
            downloadsCoordinator.navigationController
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
}
