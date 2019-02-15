//
//  FavouritesCollectionViewDataSource.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-15.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class FavouritesCollectionViewDataSource: NSObject {
    private var podcasts: [Podcast] = []
    private(set) var reuseId = "FavouriteCell"
    
    var headerId: String {
        return "FavouritesHeaderView"
    }
    
    var isEmpty: Bool {
        return podcasts.isEmpty
    }
    
    func item(at index: Int) -> Podcast? {
        guard !isEmpty else {
            return nil
        }
        
        return podcasts[index]
    }
    
    @discardableResult
    func remove(at index: Int) -> Podcast {
        guard !isEmpty else {
            fatalError("Attempting to remove but array is empty")
        }
        
        let deletedPodcast = podcasts.remove(at: index)
        UserDefaults.standard.deletePodcast(podcast: deletedPodcast)
        
        return deletedPodcast
    }
    
    func fetchFavourites(completion: @escaping (Error?) -> Void) {
        let newPodcasts = UserDefaults.standard.savedPodcasts()
        
        if newPodcasts != podcasts {
            self.podcasts = newPodcasts
            completion(nil)
        }
    }
}

extension FavouritesCollectionViewDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? FavouritePodcastCell else {
            fatalError("Unable to dequeue FavouritesPodcastCell")
        }
        
        let podcast = podcasts[indexPath.item]
        let viewModel = FavouriteCellViewModel(podcast: podcast)
        cell.configureCell(using: viewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
            headerId, for: indexPath) as? FavouritesHeaderView else {
                fatalError("Unable to dequeue FavouritesHeaderView")
        }
        
        return header
    }
}


