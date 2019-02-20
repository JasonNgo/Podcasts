//
//  Notification+Extensions.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2019-02-16.
//  Copyright © 2019 Jason Ngo. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let downloadProgress =  NSNotification.Name("downloadProgress")
    static let downloadComplete =  NSNotification.Name("downloadComplete")
    static let maximizePlayer = NSNotification.Name("maximizePlayer")
    static let minimizePlayer = NSNotification.Name("minimizePlayer")
}
