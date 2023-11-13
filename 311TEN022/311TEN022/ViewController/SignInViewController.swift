//
//  SignInViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import AuthenticationServices
import KakaoSDKUser
import SafariServices
import Alamofire

extension UIViewController {
    static func changeRootViewControllerToHome() {
        let vc = TabViewController.instantiate()
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            windowScene.windows.first?.rootViewController = vc
            windowScene.windows.first?.makeKeyAndVisible()
        }
    }
}

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginActionBtn(_ sender: Any) {
        let email = "test@gmail.com"
        let name = "happy"
        let parameter: Parameters = [
            "email": email,
            "name" : "happy"
        ]
        APIService.shared.signIn(param: parameter, completion: { res in
            
            print("memberId : \(res)")
            UserDefaults.standard.setValue(res, forKey: "memberId")
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue(name, forKey: "name")
            
            UIViewController.changeRootViewControllerToHome()
        })
        
    }
    
    
    @IBAction func kakaoSignIn(_ sender: Any) {
        // 카카오톡 설치 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    if let oauthToken = oauthToken{

                        print("kakao accessToken : \(oauthToken.accessToken)")
                    } else {
                        print("Error : User Data Not Found")
                    }
                }
            }
        }else{
            // 카카오톡 미설치인 경우 - 카카오톡 계정 로그인 웹화면으로 이동
            // (웹화면 사파리 기본 내장으로 수정)
            let kakaoUrl = URL(string: "https://accounts.kakao.com")!
            let vc = SFSafariViewController(url: kakaoUrl)
            present(vc, animated: true)
            //            UIApplication.shared.open(kakaoUrl!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func appliSigninAction(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    // 카카오 계정 정보 가져오기
    func getKakaoAccount(completion: @escaping (String, String) -> Void) {
        var myEmail = ""
        var myNickName = ""
        
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                _ = user
                if let email = user?.kakaoAccount?.email{
                    myEmail = email
                }
                if let nickName = user?.kakaoAccount?.profile?.nickname{
                    myNickName = nickName
                }
                completion(myEmail, myNickName)
            }
        }
    }
    
    @IBAction func appleSignIn(_ sender: Any) {

    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            // Apple ID
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // 계정 정보 가져오기
            // 애플은 최초 로그인때만 정보 줌;;
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            

//            let email = "test@gmail.com"
            let name = "\((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))"
//            let parameter: Parameters = [
//                "email": email,
//                "name" : name
//            ]
            
            let parameter: Parameters = [
                "email": email,
                "name" : "happy"
            ]
            APIService.shared.signIn(param: parameter, completion: { res in
                print("memberId : \(res)")
                UserDefaults.standard.setValue(res, forKey: "memberId")
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(name, forKey: "name")
                
                UIViewController.changeRootViewControllerToHome()
            })
        default:
            break
        }
    }
    
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
