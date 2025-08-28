//
//  FindUserVC.swift
//  311TEN022
//
//  Created by leeyeon2 on 8/12/25.
//

import UIKit
import Alamofire
import Lottie

let title1 = "이메일을 입력해 주세요."
let subTitle1 = "비밀번호 재설정을 위한 인증 메일이 전송됩니다."
let btnTitle1 = "이메일 인증하기"
let textFieldTitle1 = "abc@naver.com"

// 딥링크로 들어온 후
let title2 = "새로운 비밀번호를 입력해 주세요."
let subTitle2 = "영어, 숫자, 특수문자를 포함하여 8~13자리까지 입력해 주세요."
let btnTitle2 = "비밀번호 재설정하기"
let textFieldTitle2 = "비밀번호"

// 비밀번호 찾기 - 입력값 : 이메일 > 이메일로 비밀번호 재설정 링크 전송 > 딥링크로 재설정 요청 인증
class FindUserVC: UIViewController {

    @IBOutlet weak var tilteLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!{
        didSet{
            subTitleLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var inputTextField1: UITextField!
    @IBOutlet weak var inputTextField2: UITextField!
    @IBOutlet weak var findPWBtn: UIButton!
    
    // 처음 화면 세팅
    private func setinitUI() {
        tilteLabel.text = title1
        subTitleLabel.text = subTitle1
        findPWBtn.setTitle(btnTitle1, for: .normal)
        inputTextField1.placeholder = textFieldTitle1
        inputTextField1.isSecureTextEntry = false
        inputTextField2.isHidden = true
    }
    
    // 딥링크 접속 후 화면 세팅
    func pwResetUI() {
        tilteLabel.text = title2
        subTitleLabel.text = subTitle2
        findPWBtn.setTitle(btnTitle2, for: .normal)
        inputTextField1.placeholder = textFieldTitle2
        inputTextField1.isSecureTextEntry = true
        inputTextField2.isHidden = false
    }

    // 메일인증 후 비밀번호 초기화
    @IBAction func findPWAction(_ sender: Any) {
        
        if inputTextField2.isHidden {
            // 인증 메일 전송 API
            //ani 추가
            if let email = inputTextField1.text, !email.isEmpty {
                let parameter: Parameters = [
                    "email": email
                ]
                // 비밀번호 찾기 요청
                let animationView: LottieAnimationView = .init(name: "DotsAnimation")
                self.view.addSubview(animationView)
                animationView.frame = self.view.bounds
                animationView.center = self.view.center
                animationView.contentMode = .scaleAspectFit
                animationView.play()
                animationView.loopMode = .loop
                let request = APIRequest(method: .post,
                                         path: "/member/password/request",
                                         param: parameter,
                                         headers: APIConfig.headers)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
                    switch result {
                    case .success:
                        //alert
                        animationView.stop()
                        animationView.removeFromSuperview()
                        AlertView.showAlert(title: "비밀번호 재설정 링크 메일 전송 완료",
                                            message: "메일을 확인하여 비밀번호를 재설정해주세요.",
                                            viewController: self,
                                            dismissAction: nil)
                    case .failure:
                        animationView.stop()
                        animationView.removeFromSuperview()
                        AlertView.showAlert(title: "네트워크 에러 발생",
                                            message: "다시 시도해주세요.",
                                            viewController: self,
                                            dismissAction: nil)
                        print(APIError.networkFailed)
                    }
                })
            }else{
                AlertView.showAlert(title: "이메일을 입력해주세요.",
                                    message: nil,
                                    viewController: self,
                                    dismissAction: nil)
                return
            }
            // 딥링크 수신을 기다리는 상태
            // pwResetUI()는 딥링크를 통해서만 실행됨
        }else{
            // 비밀번호 재설정
            if let pw = inputTextField1.text, let _ = inputTextField2.text{
                let parameter: Parameters = [
                    "memberId": UserInfo.memberId,
                    "password": pw
                ]
                
                // 비밀번호 재설정 요청
                let request = APIRequest(method: .post,
                                         path: "/member/password/reset",
                                         param: parameter,
                                         headers: APIConfig.headers)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
                    switch result {
                    case .success(let data):
                        // 1. 회원정보 저장
                        if let responseData = data.body["data"] as? [String:Any] {
                            UserInfo.token = responseData["accessToken"] as! String
                            //alert
                            // change 말고 내리기
                            AlertView.showAlert(title: "비밀번호 재설정 완료",
                                                message: "새로운 비밀번호로 로그인해주세요.",
                                                viewController: self,
                                                dismissAction: { [weak self] in
                                self?.dismiss(animated: true, completion: nil)
                            })
                        }
                    case .failure:
                        print(APIError.networkFailed)
                    }
                })
            }else{
                AlertView.showAlert(title: "비밀번호를 입력해주세요.",
                                    message: nil,
                                    viewController: self,
                                    dismissAction: nil)
                return
    
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setinitUI()
       
        setupKeyboardNotifications()
        setupTapGesture()
        setupTextFieldDelegates()  // 텍스트필드 델리게이트 설정 추가
        
        // 딥링크 노티피케이션 등록
        setupDeepLinkNotification()
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
        // 딥링크 노티피케이션 제거
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PasswordResetDeepLink"), object: nil)
    }
    
    // MARK: - Keyboard Handling
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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        // inputTextField2가 숨겨져 있지 않다면 (비밀번호 재설정 화면이라면) 화면을 올려줌
        if !inputTextField2.isHidden {
            UIView.animate(withDuration: duration) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - safeAreaBottom) / 2)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.view.transform = .identity
        }
    }
    
    // MARK: - TextField Setup
    private func setupTextFieldDelegates() {
        inputTextField1.delegate = self
        inputTextField2.delegate = self
        
        // 텍스트필드 스타일 설정 (선택사항)
        setupTextFieldStyle(inputTextField1)
        setupTextFieldStyle(inputTextField2)
    }
    
    private func setupTextFieldStyle(_ textField: UITextField) {
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.returnKeyType = .done  // return 키를 done으로 설정
    }
    
    // MARK: - Tap Gesture Setup
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Deep Link Notification
    private func setupDeepLinkNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePasswordResetDeepLink(_:)),
            name: NSNotification.Name("PasswordResetDeepLink"),
            object: nil
        )
    }
    
    @objc private func handlePasswordResetDeepLink(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            // memberId가 있다면 저장
            if let userInfo = notification.userInfo,
               let memberId = userInfo["memberId"] as? String {
                // memberId를 저장하거나 사용
                print("받은 memberId: \(memberId)")
                // 예: UserDefaults.standard.set(memberId, forKey: "resetMemberId")
            }
            
            // 비밀번호 재설정 UI로 변경
            self?.pwResetUI()
        }
    }
}

// MARK: - UITextFieldDelegate
extension FindUserVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 텍스트필드가 활성화될 때의 스타일 변경 (선택사항)
        textField.layer.borderColor = #colorLiteral(red: 0.1294768155, green: 0.5381473899, blue: 0.4956235886, alpha: 1).cgColor
        
        // inputTextField1을 클릭할 때 inputTextField2도 보이도록 화면 조정
        if textField == inputTextField1 && !inputTextField2.isHidden {
            // inputTextField2가 화면에 완전히 보이도록 화면을 조금 더 올려줌
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.3) {
                    // 기존 transform에 추가로 올려줌
                    let additionalOffset: CGFloat = -50
                    if self.view.transform.ty < 0 {
                        // 이미 화면이 올려져 있다면 추가로 더 올려줌
                        self.view.transform = CGAffineTransform(translationX: 0, y: self.view.transform.ty + additionalOffset)
                    }
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 텍스트필드가 비활성화될 때의 스타일 변경 (선택사항)
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
