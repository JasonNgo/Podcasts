///***
// Copyright (c) 2018 Jason Ngo
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ***/
//
////
////  FavouritesCollectionViewController.swift
////  PodcastLBTA
////
////  Created by Jason Ngo on 2018-08-16.
////  Copyright © 2018 Jason Ngo. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//private class FavouritesHeaderView: UICollectionViewCell {
//  
//  let headerLabel: UILabel = {
//    let label = UILabel()
//    label.text = "No results. Please favourite a podcast."
//    label.textAlignment = .center
//    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//    return label
//  }()
//  
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    
//    addSubview(headerLabel)
//    headerLabel.translatesAutoresizingMaskIntoConstraints = false
//    headerLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//    headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//    headerLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
//  }
//  
//}
//
//class FavouritesCollectionViewController: UICollectionViewController {
//  
//  // constants
//  fileprivate let headerId = "headerId"
//  
//  fileprivate let sizeOfColumnSeparator: CGFloat = 16
//  fileprivate let numberOfColumnSeparators: CGFloat = 3
//  fileprivate let numberOfFavouriteCellsToDisplay: CGFloat = 2
//  
//  fileprivate let minimumLineSpacingForSection: CGFloat = 16
//  fileprivate struct FavouritesCellEdgeInsets {
//    static let top: CGFloat = 16
//    static let left: CGFloat = 16
//    static let bottom: CGFloat = 16
//    static let right: CGFloat = 16
//  }
//  
//  var podcasts = UserDefaults.standard.savedPodcasts()
//  
//  // MARK: - Life Cycle
//  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    podcasts = UserDefaults.standard.savedPodcasts()
//    collectionView?.reloadData()
//    UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
//  }
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    setupFavouritesCollectionView()
//  }
//  
//  // MARK: - Setup Functions
//  
//  fileprivate func setupFavouritesCollectionView() {
//    collectionView?.backgroundColor = .white
//    collectionView?.register(FavouritesPodcastCell.self, forCellWithReuseIdentifier: FavouritesPodcastCell.reuseIdentifier)
//    collectionView?.register(FavouritesHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
//    
//    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
//    collectionView?.addGestureRecognizer(longPressGesture)
//  }
//  
//  // MARK: - Selector Functions
//  
//  @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
//    let location = gesture.location(in: self.collectionView)
//    guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else { return }
//    
//    let alertController = UIAlertController(title: "Delete Podcast?", message: nil, preferredStyle: .actionSheet)
//    
//    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
//      let deletedPodcast = self.podcasts.remove(at: selectedIndexPath.item)
//      UserDefaults.standard.deletePodcast(podcast: deletedPodcast)
//      self.collectionView?.reloadData()
//    }
//    
//    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//    
//    alertController.addAction(deleteAction)
//    alertController.addAction(cancelAction)
//    present(alertController, animated: true)
//  }
//  
//}
//
//// MARK: - UICollectionViewDelegate
//
//extension FavouritesCollectionViewController {
//  
//  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    return podcasts.count
//  }
//  
//  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouritesPodcastCell.reuseIdentifier, for: indexPath) as! FavouritesPodcastCell
//    cell.podcast = podcasts[indexPath.item]
//    return cell
//  }
//  
//  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    let podcast = podcasts[indexPath.item]
//    let episodesViewController = EpisodesTableViewController()
//    episodesViewController.podcast = podcast
//    navigationController?.pushViewController(episodesViewController, animated: true)
//  }
//  
//  override func collectionView(_ collectionView: UICollectionView,
//                               viewForSupplementaryElementOfKind kind: String,
//                               at indexPath: IndexPath) -> UICollectionReusableView {
//    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
//      headerId, for: indexPath) as! FavouritesHeaderView
//    header.layoutSubviews()
//    return header
//  }
//  
//  func collectionView(_ collectionView: UICollectionView,
//                               layout collectionViewLayout: UICollectionViewLayout,
//                               referenceSizeForHeaderInSection section: Int) -> CGSize {
//    if podcasts.isEmpty {
//      return CGSize(width: collectionView.frame.width, height: 200)
//    } else {
//      return CGSize(width: 0, height: 0)
//    }
//  }
//  
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//
//extension FavouritesCollectionViewController: UICollectionViewDelegateFlowLayout {
//  
//  func collectionView(_ collectionView: UICollectionView,
//                      layout collectionViewLayout: UICollectionViewLayout,
//                      sizeForItemAt indexPath: IndexPath) -> CGSize {
//    let sizeOfOtherDisplayElements = numberOfColumnSeparators * sizeOfColumnSeparator
//    let size = (view.frame.size.width - sizeOfOtherDisplayElements) / numberOfFavouriteCellsToDisplay
//    return CGSize(width: size, height: size + 50)
//  }
//  
//  func collectionView(_ collectionView: UICollectionView,
//                      layout collectionViewLayout: UICollectionViewLayout,
//                      insetForSectionAt section: Int) -> UIEdgeInsets {
//    return UIEdgeInsets(top: FavouritesCellEdgeInsets.top,
//                        left: FavouritesCellEdgeInsets.left,
//                        bottom: FavouritesCellEdgeInsets.bottom,
//                        right: FavouritesCellEdgeInsets.right)
//  }
//  
//  func collectionView(_ collectionView: UICollectionView,
//                      layout collectionViewLayout: UICollectionViewLayout,
//                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//    return minimumLineSpacingForSection
//  }
//  
//}
