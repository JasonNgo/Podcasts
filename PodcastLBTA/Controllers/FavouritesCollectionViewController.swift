//
//  FavouritesCollectionViewController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-16.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation
import UIKit

class FavouritesCollectionViewController: UICollectionViewController {
    
    // constants
    fileprivate let favouritesCellId = "favouritesCellId"
    
    fileprivate let sizeOfColumnSeparator: CGFloat = 16
    fileprivate let numberOfColumnSeparators: CGFloat = 3
    fileprivate let numberOfFavouriteCellsToDisplay: CGFloat = 2
    
    fileprivate let minimumLineSpacingForSection: CGFloat = 16
    fileprivate struct FavouritesCellEdgeInsets {
        static let top: CGFloat = 16
        static let left: CGFloat = 16
        static let bottom: CGFloat = 16
        static let right: CGFloat = 16
    }
    
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView?.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFavouritesCollectionView()
    }
    
    // MARK: - UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: favouritesCellId, for: indexPath) as! FavouritesPodcastCell
        cell.podcast = podcasts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let podcast = podcasts[indexPath.item]
        let episodesViewController = EpisodesTableViewController()
        episodesViewController.podcast = podcast
        navigationController?.pushViewController(episodesViewController, animated: true)
    }
    
} // FavouritesCollectionViewController

// MARK: - UICollectionViewDelegateFlowLayout
extension FavouritesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfOtherDisplayElements = numberOfColumnSeparators * sizeOfColumnSeparator
        let size = (view.frame.size.width - sizeOfOtherDisplayElements) / numberOfFavouriteCellsToDisplay
        return CGSize(width: size, height: size + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: FavouritesCellEdgeInsets.top, left: FavouritesCellEdgeInsets.left,
                            bottom: FavouritesCellEdgeInsets.bottom, right: FavouritesCellEdgeInsets.right)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSection
    }
}

// MARK: - Selector Functions
private extension FavouritesCollectionViewController {
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self.collectionView)
        guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else { return }
        
        let alertController = UIAlertController(title: "Delete Podcast?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            let deletedPodcast = self.podcasts.remove(at: selectedIndexPath.item)
            UserDefaults.standard.deletePodcast(podcast: deletedPodcast)
            self.collectionView?.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// MARK: - Setup Functions
private extension FavouritesCollectionViewController {
    func setupFavouritesCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(FavouritesPodcastCell.self, forCellWithReuseIdentifier: favouritesCellId)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        collectionView?.addGestureRecognizer(longPressGesture)
    }
}
