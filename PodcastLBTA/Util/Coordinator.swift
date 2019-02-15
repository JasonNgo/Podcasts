//
//  Coordinator.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-11.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

protocol Deinitcallable: AnyObject {
    var onDeinit: (() -> Void)? { get set }
}

protocol CoordinatorProtocol: AnyObject {
    var deallocallable: Deinitcallable? { get set }
    var stop: (() -> Void)? { get set }
    
    func setDeallocallable(with object: Deinitcallable)
    func start()
}

extension CoordinatorProtocol {
    func setDeallocallable(with object: Deinitcallable) {
        deallocallable?.onDeinit = nil
        object.onDeinit = { [weak self] in
            self?.stop?()
        }
        deallocallable = object
    }
}

class Coordinator: NSObject, CoordinatorProtocol {
    weak var deallocallable: Deinitcallable?
    var stop: (() -> Void)?
    
    func start() {}
}
