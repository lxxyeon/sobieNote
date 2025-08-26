//
//  SceneDelegate.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit

import KakaoSDKAuth
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // 앱이 실행 중일 때 딥링크 처리
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url: url)
    }
    
    private func handleDeepLink(url: URL) {
        print("딥링크 수신: \(url)")
        
        // 3. 유저가 딥링크 클릭 시 앱이 열리며 토큰 처리
        // 토큰 받는 로직
        // 1. 회원가입 시 이메일 인증
        // 2. 비밀번호 찾기 이메일 인증
        if url.scheme == "sobienote" {
            if let valType = extractValParameter(from: url) {
//                print("토큰: \(token)")
                
                if valType == "reset"{
                    // 2) 비밀번호 찾기인 경우
                    if let memberId = extractMemberIdParameter(from: url) {
                        // FindUserVC가 현재 화면에 있는지 확인하고 pwResetUI() 실행
                        navigateToPasswordReset(memberId: memberId)
                    } else {
                        // memberId가 없어도 비밀번호 재설정 화면으로 이동
                        navigateToPasswordReset(memberId: nil)
                    }
                } else if valType == "SIGNUP" {
                    // 3) 회원가입 인증인 경우
                    if let accessToken = extractAccessTokenParameter(from: url) {
                        // accessToken으로 회원가입 인증 처리
                        verifyEmailWithToken(accessToken: accessToken)
                    }
                } else {
                    
                }
            }
        }
    }
    
    // 회원가입 인증인지 비밀번호 찾기 인증인지 확인
    func extractValParameter(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        return components.queryItems?.first { $0.name == "val" }?.value
    }

    // memberid 추출
    func extractMemberIdParameter(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        return components.queryItems?.first { $0.name == "memberId" }?.value
    }

    // accessToken 추출
    func extractAccessTokenParameter(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        return components.queryItems?.first { $0.name == "accessToken" }?.value
    }

    
    
    
    // 비밀번호 재설정 화면으로 이동하는 함수
    private func navigateToPasswordReset(memberId: String?) {
        // 현재 FindUserVC가 표시되어 있는지 확인
        if let currentVC = getCurrentViewController() as? FindUserVC {
            // FindUserVC가 현재 화면이라면 NotificationCenter로 알림 전송
            sendPasswordResetNotification(memberId: memberId)
        } else {
            // FindUserVC가 현재 화면이 아니라면 먼저 FindUserVC를 popup으로 띄운 후 알림 전송
            presentFindUserVCWithPasswordReset(memberId: memberId)
        }
    }
    
    private func sendPasswordResetNotification(memberId: String?) {
        var userInfo: [String: Any] = [:]
        if let memberId = memberId {
            userInfo["memberId"] = memberId
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("PasswordResetDeepLink"),
            object: nil,
            userInfo: userInfo
        )
    }
    
    // 비밀번호 재설정 인증 완료
    private func verifyEmailResetPWWithToken(token: String) {
        print("비밀번호 재설정 인증 완료")
    }
    
    // 회원 가입 인증 완료
    private func verifyEmailWithToken(accessToken: String?) {
        // accessToken이 있으면 사용, 없으면 기본 처리
        if let token = accessToken {
            // accessToken을 사용한 인증 로직
            print("받은 accessToken: \(token)")
            // API 호출 등 실제 인증 로직
            // 토큰 저장 및 홈화면 이동
            UserInfo.token = token
        } else {
            // accessToken이 없는 경우 기본 처리
            print("accessToken이 없습니다.")
            return
        }
      
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            // ViewController를 찾지 못한 경우 바로 홈화면으로 이동
            DispatchQueue.main.async {
                UIViewController.changeRootVCToHomeTab()
            }
            return
        }
        
        // 현재 최상위 ViewController 찾기
        let currentViewController = findTopViewController(from: rootViewController)
        
        DispatchQueue.main.async {
            AlertView.showAlert(title: "회원가입이 완료되었습니다. 😊",
                               message: "소비채집을 시작해보세요.",
                               viewController: currentViewController) {
                UIViewController.changeRootVCToHomeTab()
            }
        }
    }
    
    // 최상위 ViewController 찾는 헬퍼 함수
    private func findTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return findTopViewController(from: presentedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return findTopViewController(from: navigationController.visibleViewController ?? navigationController)
        } else if let tabBarController = viewController as? UITabBarController {
            return findTopViewController(from: tabBarController.selectedViewController ?? tabBarController)
        }
        return viewController
    }
    
    // 앱이 종료된 상태에서 딥링크로 실행될 때 처리
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // 딥링크로 앱이 실행된 경우
        if let urlContext = connectionOptions.urlContexts.first {
            handleDeepLink(url: urlContext.url)
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func extractToken(from url: URL) -> String? {
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "token" })?
            .value
    }
    
    // 현재 표시중인 ViewController 가져오기
    private func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        return findTopViewController(from: rootViewController)
    }
    
    // FindUserVC를 popup 방식으로 표시하고 비밀번호 재설정 모드로 설정
    private func presentFindUserVCWithPasswordReset(memberId: String?) {
        // SignInViewController를 찾아서 findmember 버튼 액션 실행
        if let signInVC = getCurrentViewController() as? SignInViewController {
            // SignInViewController가 현재 화면인 경우
            presentFindUserVCFromSignIn(signInVC: signInVC, memberId: memberId)
        } else {
            // 다른 화면인 경우 SignInViewController로 이동 후 FindUserVC present
            navigateToSignInAndPresentFindUser(memberId: memberId)
        }
    }
    
    private func presentFindUserVCFromSignIn(signInVC: SignInViewController, memberId: String?) {
        // findmember 버튼 클릭을 시뮬레이트하여 FindUserVC를 popup으로 띄움
        DispatchQueue.main.async {
            // Segue를 통해 FindUserVC를 present
            signInVC.performSegue(withIdentifier: "showFindUser", sender: nil)
            
            // Segue가 완료된 후 NotificationCenter로 알림 전송
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sendPasswordResetNotification(memberId: memberId)
            }
        }
    }
    
    private func navigateToSignInAndPresentFindUser(memberId: String?) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // SignInViewController로 이동
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signInVC = storyboard.instantiateViewController(withIdentifier: "SignIn") as? SignInViewController {
            
            DispatchQueue.main.async {
                window.rootViewController = signInVC
                
                // SignInViewController 로드 완료 후 FindUserVC present
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.presentFindUserVCFromSignIn(signInVC: signInVC, memberId: memberId)
                }
            }
        }
    }
}

