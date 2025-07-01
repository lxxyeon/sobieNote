//
//  AppDelegate.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import AuthenticationServices
import KakaoSDKCommon
import KakaoSDKAuth
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    final class AppAppearance {
        static func setupAppearance() {
            UITabBar.appearance().tintColor = UIColor(hexCode: "21897e")
            UITabBar.appearance().backgroundColor = UIColor(hexCode: "f0faf9")
        }
    }

     func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         var handled: Bool

         handled = GIDSignIn.sharedInstance.handle(url)
         if handled {
           return true
         }
       
         if (AuthApi.isKakaoTalkLoginUrl(url)) {
             return AuthController.handleOpenUrl(url: url)
         }
         return false
     }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //탭바 기본 색상 설정
        AppAppearance.setupAppearance()
        
        //launchScreen 보여주는 시간 추가
        sleep(2)
        
        //kakao init
        KakaoSDK.initSDK(appKey: "da34c776779354fda0a431b36464bf3a")
        
        //apple init
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        //forUserID = userIdentifier
        appleIDProvider.getCredentialState(forUserID: "001281.9301aaa1f617423c9c7a64b671b6eb84.0758") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                print("해당 ID는 연동되어있습니다.")
            case .revoked, .notFound:
                print("해당 ID를 찾을 수 없습니다.")
            default:
                break
            }
        }
        
        //앱 실행 중 강제로 연결 취소 시
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { (Notification) in
            print("Revoked Notification")
            // 로그인 페이지로 이동
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
