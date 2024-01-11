//
//  SignInViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import AuthenticationServices
import KakaoSDKUser
import Alamofire

class SignInViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 최초 로그인 이후 자동로그인 설정
        if UserInfo.token.count > 0 {
            UIViewController.changeRootVCToHomeTab()
        }
    }
    
    func setKakaoUserInfo() {
        // 카카오 계정 정보 가져오기
        UserApi.shared.me {(user, error) in
            if let error = error {
                print(error)
            } else {
                //email, nickname
                print("nickname: \(user?.kakaoAccount?.profile?.nickname ?? "no nickname")")
                print("email: \(user?.kakaoAccount?.email ?? "no email")")
                
                let signInParameter: Parameters = [
                    "email": user?.kakaoAccount?.email ?? "no email",
                    "name" : user?.kakaoAccount?.profile?.nickname ?? "no email"
                ]
                
                APIService.shared.signIn(param: signInParameter, completion: { res in
                    print("memberId : \(res)")
                    UserDefaults.standard.setValue(res, forKey: "memberId")
                    UserDefaults.standard.setValue(user?.kakaoAccount?.email ?? "no email", forKey: "email")
                    UserDefaults.standard.setValue(user?.kakaoAccount?.profile?.nickname ?? "no email", forKey: "name")
                    UIViewController.changeRootVCToHomeTab()
                })
            }
        }
    }
    
    // 소셜로그인 1. 카카오
    @IBAction func kakaoSignInButton(_ sender: Any) {
        // 카카오톡 설치 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                // oauthToken?.accessToken
                if let error = error {
                    AlertView.showAlert(title: Global.kakaoSignInErrorTitle,
                                        message: Global.kakaoSignInErrorMessage,
                                        viewController: self,
                                        dismissAction: nil)
                }
                else {
                    self.setKakaoUserInfo()
                }
            }
        }else{
            // 카카오톡 미설치인 경우 - 카카오톡 계정 로그인 웹화면으로 이동
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    AlertView.showAlert(title: Global.kakaoSignInErrorTitle,
                                        message: Global.kakaoSignInErrorMessage,
                                        viewController: self,
                                        dismissAction: nil)
                }
                else {
                    _ = oauthToken
                    self.setKakaoUserInfo()
                }
            }
        }
    }
    
    // 소셜로그인 2. Apple
    @IBAction func appleSignInButton(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Apple ID 연동 성공 시 수행
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            //로그인 성공
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // 최초 로그인때만 정보 저장
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            let name = "\((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))"
            let parameter: Parameters = [
                "email": "\(email ?? "")",
                "name" : name
            ]
            
            APIService.shared.signIn(param: parameter, completion: { res in
                print("memberId : \(res)")
                UserDefaults.standard.setValue(res, forKey: "memberId")
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(name, forKey: "name")
                
                UIViewController.changeRootVCToHomeTab()
            })
        default:
            AlertView.showAlert(title: Global.appleSignInErrorTitle,
                                message: Global.appleSignInErrorMessage,
                                viewController: self,
                                dismissAction: nil)
            break
        }
    }
    
    // Apple ID 연동 실패 시 수행
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AlertView.showAlert(title: Global.appleSignInErrorTitle,
                            message: Global.appleSignInErrorMessage,
                            viewController: self,
                            dismissAction: nil)
    }
}

