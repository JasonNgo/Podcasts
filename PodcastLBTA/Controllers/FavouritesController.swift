//
//  FavouritesController.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-16.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation
import UIKit

class FavouritesController: UICollectionViewController {
    
    fileprivate let cellId = "cellId"
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    // MARK: - Lifecycle Functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView?.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    // MARK: - UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavouritesPodcastCell
        cell.podcast = podcasts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let podcast = podcasts[indexPath.item]
        let episodesController = EpisodesController()
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
} // FavouritesController

// MARK: - UICollectionViewDelegateFlowLayout
extension FavouritesController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.frame.size.width - (3 * 16)) / 2
        return CGSize(width: size, height: size + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - Selector Functions
private extension FavouritesController {
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self.collectionView)
        guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else { return }
        
        let alertController = UIAlertController(title: "Delete Podcast?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            let removedPodcast = self.podcasts.remove(at: selectedIndexPath.item)
            UserDefaults.standard.deletePodcast(podcast: removedPodcast)
            self.collectionView?.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - Setup Functions
private extension FavouritesController {
    func setupCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(FavouritesPodcastCell.self, forCellWithReuseIdentifier: cellId)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        collectionView?.addGestureRecognizer(gesture)
    }
}
