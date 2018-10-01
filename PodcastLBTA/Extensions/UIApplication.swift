//
//  UIApplication.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-15.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
