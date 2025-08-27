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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tabBar.frame.size.height = 90
    }
}

extension UIViewController {
    // 설정화면으로 이동
    static func changeRootVCToSettingMenu() {
        let vc = SettingInfoViewController.instantiate()
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            windowScene.windows.first?.rootViewController = vc
            windowScene.windows.first?.makeKeyAndVisible()
        }
    }
    
    // 탭화면으로 이동
    static func changeRootVCToHomeTab() {
        let vc = TabViewController.instantiate()
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            windowScene.windows.first?.rootViewController = vc
            windowScene.windows.first?.makeKeyAndVisible()
        }
    }
    
    // 로그인 화면으로 이동
    static func changeRootVCToSignIn() {
        let vc = SignInViewController.instantiate()
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            windowScene.windows.first?.rootViewController = vc
            windowScene.windows.first?.makeKeyAndVisible()
        }
    }
}
