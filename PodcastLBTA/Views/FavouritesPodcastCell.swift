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

}

// MARK: - Setup helper functions

fileprivate extension FavouritesPodcastCell {
    
    func setupFavouriteCellStyling() {
        titleLabel.text = "Podcast Title"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        authorLabel.text = "Podcast Author"
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .lightGray
    }
    
    func setupFavouriteCellViews() {
        thumbnailImageView.backgroundColor = .red
        thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [thumbnailImageView, titleLabel, authorLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
}
