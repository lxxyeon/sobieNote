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
import GoogleSignIn
import Lottie

class SignInViewController: UIViewController, StoryboardInitializable, UITextFieldDelegate {
    static var storyboardID: String = "SignIn"
    static var storyboardName: String = "Main"
    
    // 키보드 높이 조절을 위한 변수
    private var originalViewY: CGFloat = 0
    private var isKeyboardShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI
        setupTapGesture()
        setupKeyboardNotifications()
        originalViewY = view.frame.origin.y
        // 비밀번호 입력값 보이게
        setupPasswordToggle()
        
        // 탭화면 테스트용
//        UIViewController.changeRootVCToHomeTab()
        
        // 최초 로그인 이후 자동로그인 설정
        UserInfo.token = String(UserDefaults.standard.string(forKey: "token") ?? "")
        if UserInfo.token.count > 0 {
            print("🔥🔥자동로그인 성공🔥🔥")
            UIViewController.changeRootVCToHomeTab()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    @IBOutlet weak var emailTextField: UITextField!{
        didSet{
            emailTextField.delegate = self
            emailTextField.font = UIFont.kimR18()
            emailTextField.clearButtonMode = .always
        }
    }
    
    @IBOutlet weak var pwTextField: UITextField!{
        didSet{
            pwTextField.delegate = self
            pwTextField.font = UIFont.kimR18()
        }
    }
    
    //로그인 버튼 custom
    @IBOutlet weak var SignInBtn: UIButton!{
        didSet{
            SignInBtn.layer.cornerRadius = 25
            SignInBtn.titleLabel?.font = UIFont.kimB18()
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
    
    @IBOutlet weak var googleSignInButton: UIButton!{
        didSet{
            let image = UIImage(named: "logo_google")?.imageWith(newSize: .init(width: 40, height: 40))
            googleSignInButton.setImage(image, for: .normal)
            googleSignInButton.configuration?.imagePadding = 8
        }
    }
    
    @IBOutlet weak var signUpBtn: UIButton!{
        didSet{
            signUpBtn.titleLabel?.font = UIFont.kimB16()
        }
    }
    
    @IBOutlet weak var findMemberBtn: UIButton!{
        didSet{
            findMemberBtn.titleLabel?.font = UIFont.kimB16()
        }
        
    }
    
    // 자체 로그인 수행
    @IBAction func signInAction(_ sender: Any) {
        if let userEmail = emailTextField.text, !userEmail.isEmpty {
            if let userPassword = pwTextField.text, !userPassword.isEmpty {
                let signInParameter: Parameters = [
                    "email": userEmail,
                    "password": userPassword
                ]
                let animationView: LottieAnimationView = .init(name: "DotsAnimation")
                self.view.addSubview(animationView)
                animationView.frame = self.view.bounds
                animationView.center = self.view.center
                animationView.contentMode = .scaleAspectFit
                animationView.play()
                animationView.loopMode = .loop
                APIService.shared.signIn(param: signInParameter, completion: { res in
                    if let userInfo = res {
                        //            UserInfo.name = name
                        //            UserInfo.email = userInfo
                        UserInfo.email = userEmail
                        animationView.stop()
                        animationView.removeFromSuperview()
                        UIViewController.changeRootVCToHomeTab()
                    }else{
                        // 로그인 에러 출력
                        animationView.stop()
                        animationView.removeFromSuperview()
                        AlertView.showAlert(title: "로그인에 실패했습니다.",
                                            message: "로그인 정보를 확인해주세요.",
                                            viewController: self,
                                            dismissAction: nil)
                    }
                })
            }else{
                AlertView.showAlert(title: "비밀번호를 입력하세요.",
                                    message: nil,
                                    viewController: self,
                                    dismissAction: nil)
            }
        }else{
            AlertView.showAlert(title: "이메일을 입력하세요.",
                                message: nil,
                                viewController: self,
                                dismissAction: nil)
        }
    }
    
    // TextField에 비밀번호 토글 버튼 추가하는 함수
    func setupPasswordToggle() {
        // 첫 번째 비밀번호 필드에 토글 버튼 추가
        addPasswordToggleButton(to: pwTextField)
        
    }
    
    // 개별 텍스트필드에 비밀번호 토글 버튼 추가하는 함수
    private func addPasswordToggleButton(to textField: UITextField) {
        // 토글 버튼 생성
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        // 버튼 클릭 시 호출될 액션 추가
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // 버튼을 감싸는 뷰 생성 (여백 추가를 위해)
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        containerView.addSubview(toggleButton)
        
        // 텍스트필드의 오른쪽에 버튼 추가
        textField.rightView = containerView
        textField.rightViewMode = .always
        
        // 텍스트필드에 태그 지정 (어떤 필드의 버튼이 눌렸는지 구분하기 위해)
        if textField == pwTextField {
            toggleButton.tag = 1
        }
    }
    
    // MARK: - 키보드 관련 메서드
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard !isKeyboardShown else { return }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let screenHeight = view.frame.height
            let availableSpace = screenHeight - keyboardHeight
            
            // 기준이 되는 텍스트필드 결정
            var targetTextField: UITextField
            
            if emailTextField.isFirstResponder {
                // 이메일 필드 클릭 시 pwTextField가 키보드 위로 보이도록
                targetTextField = pwTextField
            } else if pwTextField.isFirstResponder {
                // 비밀번호 필드 클릭 시 자기 자신이 보이도록
                targetTextField = pwTextField
            } else {
                return
            }
            
            // 타겟 텍스트필드의 절대 좌표 계산
            let textFieldFrame = targetTextField.convert(targetTextField.bounds, to: view)
            let textFieldBottom = textFieldFrame.maxY
            
            // 타겟 텍스트필드가 키보드에 가려지는지 확인
            if textFieldBottom > availableSpace {
                let moveUpDistance = textFieldBottom - availableSpace + 50 // 여유 공간 30pt 추가
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = -moveUpDistance
                }
                isKeyboardShown = true
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard isKeyboardShown else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
        isKeyboardShown = false
    }
    
    // 키보드 내리기
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: - 소셜로그인
    
    // 소셜로그인 3. 구글
    @IBAction func googleSignInButton(_ sender: Any) {
        signInWithGoogle()
    }
    
    private func signInWithGoogle() {
        // Get the client ID from your GoogleService-Info.plist
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else { return }
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                AlertView.showAlert(title: "Google 로그인 오류",
                                    message: "Google 로그인 중 오류가 발생했습니다. 다시 시도해 주세요.",
                                    viewController: self,
                                    dismissAction: nil)
                return
            }
            
            // Get user's email and name from Google account
            
            let email = signInResult?.user.profile?.email ?? ""
            let name = signInResult?.user.profile?.name ?? ""
            
            // Call your API service to sign in
            let signInParameter: Parameters = [
                "email": email,
                "name": name,
                "type": "GOOGLE"
            ]
            
            //소셜 api로 변경 수정 필요
            APIService.shared.signInSocial(param: signInParameter,
                                           type: "GOOGLE",
                                           completion: { res in
                print("Google signin memberId: \(res)")
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(name, forKey: "name")
                UserInfo.nickName = name
                UserInfo.email = email
                UIViewController.changeRootVCToHomeTab()
            })
        }
    }
    // 아이디 placeholder : C5C5C7
    // 로그인 버튼: E3F6F2/ font 555555
    // 가입하기 font 212121
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // 닉네임, 비밀번호, 이메일
    // 회원가입, 자체 로그인, 회원 수정, 회원 삭제(탈퇴)
    // api
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
                    "name" : user?.kakaoAccount?.profile?.nickname ?? "no email",
                    "type" : "KAKAO"
                ]
                
                APIService.shared.signInSocial(param: signInParameter,
                                               type: "KAKAO",
                                               completion: { res in
                    // 카카오 로그인 실패
                    if res == nil {
                        AlertView.showAlert(title: Global.kakaoSignInErrorTitle,
                                            message: Global.kakaoSignInErrorMessage,
                                            viewController: self,
                                            dismissAction: nil)
                    }else{
                        // 카카오 로그인 성공
                        UserDefaults.standard.setValue(user?.kakaoAccount?.email ?? "no email", forKey: "email")
                        UserDefaults.standard.setValue(user?.kakaoAccount?.profile?.nickname ?? "no email", forKey: "name")
                    
                        UserInfo.nickName = user?.kakaoAccount?.profile?.nickname ?? "no nickname"
                        UserInfo.email = user?.kakaoAccount?.email ?? "no email"
                        // 환경설정으로 넘어가기x
                        // 홈화면으로 이동
                        UIViewController.changeRootVCToHomeTab()
                    }
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
                    // 카카오 인증 성공 후 social API 수행
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
                "name" : appleName,
                "type" : "APPLE"
            ]
            
            APIService.shared.signInSocial(param: parameter,
                                           type: "APPLE",
                                           completion: { res in
                UserDefaults.standard.setValue(appleEmail, forKey: "email")
                UserDefaults.standard.setValue(appleName, forKey: "name")
                UserInfo.nickName = appleName
                UserInfo.email = appleEmail
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

extension SignInViewController {
    // 비밀번호 표시/숨김 토글 액션
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        // 버튼 태그로 어떤 텍스트필드의 버튼인지 확인
        let textField: UITextField = pwTextField
        
        // 비밀번호 표시 상태 전환
        textField.isSecureTextEntry.toggle()
        
        // 버튼 아이콘 변경
        if textField.isSecureTextEntry {
            sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    // 화면 터치 시 키패드 내리기 위한 탭 제스처 설정
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // 탭 제스처가 다른 터치 이벤트를 방해하지 않도록 설정
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}
