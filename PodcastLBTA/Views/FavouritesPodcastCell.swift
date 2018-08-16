//
//  FavouritesPodcastCell.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-16.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit

class FavouritesPodcastCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUIStyling()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup functions
    
    fileprivate func setupUIStyling() {
        titleLabel.text = "Podcast Title"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        authorLabel.text = "Podcast Author"
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .lightGray
    }
    
    fileprivate func setupViews() {
        imageView.backgroundColor = .red
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, authorLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
