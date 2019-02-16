//
//  SearchTableViewDataSource.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-14.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

// TODO: Add delayed API Call

class SearchTableViewDataSource: NSObject {
    private var podcasts: [Podcast] = []
    private(set) var reuseId = "PodcastCell"
    
    var isEmpty: Bool {
       return podcasts.isEmpty
    }
    
    func item(at index: Int) -> Podcast? {
        guard !podcasts.isEmpty else {
            return nil
        }
        
        return podcasts[index]
    }
    
    func searchItems(with searchText: String, completion: @escaping (Error?) -> Void) {
        APIService.shared.fetchPodcastsWith(searchText: searchText) { (podcasts) in
            self.podcasts = podcasts
            completion(nil)
        }
    }
}

extension SearchTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? PodcastCell else {
            fatalError("Error attempting to cast PodcastCell")
        }
        
        let podcast = podcasts[indexPath.row]
        let viewModel = PodcastCellViewModel(podcast: podcast)
        cell.configureCell(with: viewModel)
        
        return cell
    }
}
