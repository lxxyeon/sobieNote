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

class SignInViewController: UIViewController, StoryboardInitializable {
    static var storyboardID: String = "SignIn"
    static var storyboardName: String = "Main"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 로그인 안될 때 화면에서 테스트하기 위함
//        UIViewController.changeRootVCToHomeTab()
        // 최초 로그인 이후 자동로그인 설정
        if UserInfo.token.count > 0 {
            UIViewController.changeRootVCToHomeTab()
        }
    }
    
    @IBOutlet weak var kakaoSignInButton: UIButton!{
        didSet{
            let image = UIImage(named: "logo_kakao")?.imageWith(newSize: .init(width: 30, height: 30))
            kakaoSignInButton.setImage(image, for: .normal)
            kakaoSignInButton.configuration?.imagePadding = 8
        }
    }

    @IBOutlet weak var appleSignInButton: UIButton!{
        didSet{
            let image = UIImage(named: "logo_apple")?.imageWith(newSize: .init(width: 30, height: 30))
            appleSignInButton.setImage(image, for: .normal)
            appleSignInButton.configuration?.imagePadding = 8
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
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
                if error != nil {
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
                if error != nil {
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
            // 로그인 성공 - 최초 로그인때만 이메일, 이름 정보 저장
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            
            var appleEmail: String = ""
            var appleName: String = ""

            if let email = appleIDCredential.email{
                // 1. 같은 단말기 최초 애플 로그인인 경우
                let givenName = appleIDCredential.fullName?.givenName
                let familyName = appleIDCredential.fullName?.familyName

                appleEmail = email
                appleName = "\((givenName ?? "") + (familyName ?? ""))"
                
                let userAccount = Account(email: appleEmail,
                                          name: appleName) 
                
                if let userAccountData = try? JSONEncoder().encode(userAccount){
                    if !KeychainManager().saveItem(userIdentifier: userIdentifier,
                                                   account: userAccountData){
                        //키체인 저장 실패
                        AlertView.showAlert(title: Global.appleSignInErrorTitle,
                                            message: Global.appleSignInErrorMessage,
                                            viewController: self,
                                            dismissAction: nil)
                    }
                }
            }else{
                // 2. 최초 로그인이 아닌 경우
                if let userAccount = KeychainManager().readItem(userIdentifier: userIdentifier){
                    appleEmail = userAccount.email
                    appleName = userAccount.name
                }else{
                    //키체인 불러오기 실패
                    AlertView.showAlert(title: Global.appleSignInErrorTitle,
                                        message: Global.appleSignInErrorMessage,
                                        viewController: self,
                                        dismissAction: nil)
                }
            }
            
            let parameter: Parameters = [
                "email": appleEmail,
                "name" : appleName
            ]
            
            APIService.shared.signIn(param: parameter, 
                                     completion: { res in
                print("memberId : \(res)")
                UserDefaults.standard.setValue(res, forKey: "memberId")
                UserDefaults.standard.setValue(appleEmail, forKey: "email")
                UserDefaults.standard.setValue(appleName, forKey: "name")
                
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

