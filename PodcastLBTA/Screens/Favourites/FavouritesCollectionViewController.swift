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
//  FavouritesCollectionViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-16.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

protocol FavouritesCollectionViewDelegate: AnyObject {
    func favouritesCollectionViewDidSelect(podcast: Podcast)
}

class FavouritesCollectionViewController: UICollectionViewController, Deinitcallable {

    // MARK: - Configurations
    private let insetForSection = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    private let minimumLineSpacingForSection: CGFloat = 16
    private let sizeOfColumnSeparator: CGFloat = 16
    private let numberOfColumnSeparators: CGFloat = 3
    private let numberOfFavouriteCellsToDisplay: CGFloat = 2
    
    // MARK: - Dependencies
    private let dataSource: FavouritesCollectionViewDataSource
    
    weak var delegate: FavouritesCollectionViewDelegate?
    
    // MARK: -  Init/Deinit
    
    var onDeinit: (() -> Void)?
    
    deinit {
        onDeinit?()
    }
    
    init(dataSource: FavouritesCollectionViewDataSource) {
        let layout = UICollectionViewFlowLayout()
        self.dataSource = dataSource
        super.init(collectionViewLayout: layout)
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFavourites()
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFavouritesCollectionView()
        fetchFavourites()
    }
    
    // MARK: - Setup Functions
    
    private func setupFavouritesCollectionView() {
        collectionView.register(FavouritePodcastCell.self, forCellWithReuseIdentifier: dataSource.reuseId)
        collectionView.register(FavouritesHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: dataSource.headerId)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self.dataSource
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Selector Functions
    
    @objc private func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self.collectionView)
        guard let selectedIndexPath = collectionView.indexPathForItem(at: location) else { return }
        
        let alertController = UIAlertController(title: "Delete Podcast?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.dataSource.remove(at: selectedIndexPath.item)
            self.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Helpers
    
    private func fetchFavourites() {
        dataSource.fetchFavourites { (error) in
            if let _ = error {
                // TODO: Error state
                return
            }
            
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Required
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate

extension FavouritesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let podcast = dataSource.item(at: indexPath.item) else { return }
        delegate?.favouritesCollectionViewDidSelect(podcast: podcast)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if dataSource.isEmpty {
            return CGSize(width: collectionView.frame.width, height: 400)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FavouritesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfOtherDisplayElements = numberOfColumnSeparators * sizeOfColumnSeparator
        let size = (view.frame.size.width - sizeOfOtherDisplayElements) / numberOfFavouriteCellsToDisplay
        return CGSize(width: size, height: size + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insetForSection
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSection
    }
}
