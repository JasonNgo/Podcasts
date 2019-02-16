//
//  DownloadsCoordinator.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-15.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class DownloadsCoordinator: Coordinator {
    // MARK: - Dependencies
    private let dataSource: DownloadsTableViewDataSource
    
    let navigationController: UINavigationController
    private var downloadsController: DownloadsTableViewController?
    
    init(navigationController: UINavigationController, dataSource: DownloadsTableViewDataSource) {
        self.navigationController = navigationController
        self.dataSource = dataSource
        super.init()
        
        setupNavigationControllerStyling()
    }
    
    private func setupNavigationControllerStyling() {
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    override func start() {
        let downloadsController = DownloadsTableViewController(dataSource: dataSource)
        downloadsController.title = "Downloads"
        downloadsController.tabBarItem.title = "Downloads"
        downloadsController.tabBarItem.image = #imageLiteral(resourceName: "downloads").withRenderingMode(.alwaysOriginal)
        navigationController.pushViewController(downloadsController, animated: false)
        self.downloadsController = downloadsController
    }
}
