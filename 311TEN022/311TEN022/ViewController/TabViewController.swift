//
//  TabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit

class TabViewController: UITabBarController, StoryboardInitializable {
    static var storyboardID: String = "MainPage"
    static var storyboardName: String = "Main"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.layer.cornerRadius = self.tabBar.frame.height * 0.41
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
