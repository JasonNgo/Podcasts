//
//  FavouritesHeaderView.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-15.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

class FavouritesHeaderView: UICollectionViewCell {

    // MARK: - Subviews
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "No results. Please favourite a podcast."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        contentView.addSubview(headerLabel)
        headerLabel.centerInSuperview()
        headerLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Required
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
