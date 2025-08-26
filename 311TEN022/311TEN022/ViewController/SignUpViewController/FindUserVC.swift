//
//  FindUserVC.swift
//  311TEN022
//
//  Created by leeyeon2 on 8/12/25.
//

import UIKit
import Alamofire

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
            if let email = inputTextField1.text, !email.isEmpty {
                let parameter: Parameters = [
                    "email": email
                ]
                // 비밀번호 찾기 요청
                let request = APIRequest(method: .post,
                                         path: "/member/password/request",
                                         param: parameter,
                                         headers: APIConfig.headers)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
                    switch result {
                    case .success:
                        //alert
                        AlertView.showAlert(title: "비밀번호 재설정 링크 메일 전송 완료",
                                            message: "메일을 확인하여 비밀번호를 재설정해주세요.",
                                            viewController: self,
                                            dismissAction: nil)
                    case .failure:
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
            if let pw = inputTextField1.text, let pw2 = inputTextField2.text{
                let parameter: Parameters = [
                    "memberId": 2,
                    "password": pw
                ]
                
                // 비밀번호 찾기 요청
                let request = APIRequest(method: .post,
                                         path: "/member/password/reset",
                                         param: parameter,
                                         headers: APIConfig.headers)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
                    switch result {
                    case .success:
                        //alert
                        AlertView.showAlert(title: "비밀번호 재설정 링크 안내 메일을 전송하였습니다.",
                                            message: "메일을 확인하여 비밀번호 재설정을 완료해주세요.",
                                            viewController: self,
                                            dismissAction: nil)
                    case .failure:
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setinitUI()
       
        setupKeyboardNotifications()
        setupTapGesture()
        
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
        
        UIView.animate(withDuration: duration) {
//            self.view.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - safeAreaBottom))
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 텍스트필드가 비활성화될 때의 스타일 변경 (선택사항)
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
}
