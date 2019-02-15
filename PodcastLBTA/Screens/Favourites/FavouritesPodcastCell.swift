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
//  FavouritesPodcastCell.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-16.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class FavouritesPodcastCell: UICollectionViewCell {
  
  let thumbnailImageView = UIImageView()
  let titleLabel = UILabel()
  let authorLabel = UILabel()
  
  static let reuseIdentifier = "favouritesCellId"
  
  var podcast: Podcast! {
    didSet {
      titleLabel.text = podcast.trackName
      authorLabel.text = podcast.artistName
      
      guard let imageUrl = URL(string: podcast.artworkUrl600 ?? "") else { return }
      thumbnailImageView.sd_setImage(with: imageUrl, completed: nil)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupFavouriteCellStyling()
    setupFavouriteCellViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  fileprivate func setupFavouriteCellStyling() {
    titleLabel.text = "Podcast Title"
    titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    authorLabel.text = "Podcast Author"
    authorLabel.font = UIFont.systemFont(ofSize: 14)
    authorLabel.textColor = .lightGray
  }
  
  fileprivate func setupFavouriteCellViews() {
    thumbnailImageView.backgroundColor = .red
    thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor).isActive = true
    
    let stackView = UIStackView(arrangedSubviews: [
      thumbnailImageView,
      titleLabel,
      authorLabel
    ])
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    
    addSubview(stackView)
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
  }
  
}
