//
//  SignUpNameVC.swift
//  311TEN022
//
//  Created by leeyeon2 on 4/26/25.
//

import UIKit

// 회원가입 정보 싱글톤
class UserSignupModel {
    static let shared = UserSignupModel()
    
    var nickName: String = ""
    var password: String = ""
    var email: String = ""
    
    // 강원도 정보
    var age: Int? = nil
    var school: String? = nil
    private init() {}
}

// 회원가입 -  1.닉네임 입력 화면
class SignUpNameVC: UIViewController {
    
    // 로딩 uiview
    @IBOutlet weak var loading1: UIView!{
        didSet {
            loading1.layer.cornerRadius = 8
            loading1.layer.borderColor = UIColor(hexCode: "B1E7E1").cgColor
            // 테두리 두께 설정
            loading1.layer.borderWidth = 1.0
            // 뷰 내용이 둥근 모서리에 맞게 잘리도록 설정 (선택사항)
            loading1.clipsToBounds = true
        }
    }
    @IBOutlet weak var loading2: UIView!
    {
        didSet {
            loading2.layer.cornerRadius = 8
            loading2.layer.borderColor = UIColor.systemGray6.cgColor
            // 테두리 두께 설정
            loading2.layer.borderWidth = 1.0
            // 뷰 내용이 둥근 모서리에 맞게 잘리도록 설정 (선택사항)
            loading2.clipsToBounds = true
        }
    }
    @IBOutlet weak var loading3: UIView!
    {
        didSet {
            loading3.layer.cornerRadius = 8
            loading3.layer.borderColor = UIColor.systemGray6.cgColor
            // 테두리 두께 설정
            loading3.layer.borderWidth = 1.0
            // 뷰 내용이 둥근 모서리에 맞게 잘리도록 설정 (선택사항)
            loading3.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    // 활성화된 버튼 색상 (청록색)
    private let activeButtonColor = UIColor.Point()
    
    // 비활성화된 버튼 색상 (회색)
    private let inactiveButtonColor = UIColor.systemGray6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기 버튼 설정
        setupNextButton()
        
        // 텍스트 필드 delegate 설정
        nameTextField.delegate = self
        
        // 텍스트 변경 이벤트 추가
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // 화면 터치 시 키패드 내리기 위한 탭 제스처 추가
        setupTapGesture()
        nameTextField.clearButtonMode = .always
    }
    
    // 버튼 초기 설정
    private func setupNextButton() {
        nextBtn.layer.cornerRadius = 8
        // 초기 상태는 비활성화
        updateButtonState(isEnabled: false)
    }
    
    // 버튼 상태 업데이트 함수
    private func updateButtonState(isEnabled: Bool) {
        nextBtn.isEnabled = isEnabled
        if isEnabled {
            // 활성화 상태: 청록색
            nextBtn.configuration?.baseBackgroundColor = activeButtonColor
            nextBtn.configuration?.baseForegroundColor = UIColor.white
        } else {
            // 비활성화 상태: 회색
            nextBtn.backgroundColor = inactiveButtonColor
        }
    }
    
    // 텍스트 필드 변경 감지 메서드
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // 텍스트가 비어있지 않은 경우 버튼 활성화
        if let text = textField.text, !text.isEmpty {
            updateButtonState(isEnabled: true)
        } else {
            updateButtonState(isEnabled: false)
        }
    }
    
    // 회원가입 정보 전달 - 닉네임
    @IBAction func nextBtnAction(_ sender: Any) {
        UserSignupModel.shared.nickName = nameTextField.text ?? ""
    }
}

// MARK: - UITextFieldDelegate
extension SignUpNameVC: UITextFieldDelegate {
    // 키보드에서 Return 키 눌렀을 때 처리
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 내리기
        return true
    }
    
    // 텍스트 필드 편집이 끝났을 때 호출
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 텍스트 유효성 다시 확인
        if let text = textField.text, !text.isEmpty {
            updateButtonState(isEnabled: true)
        } else {
            updateButtonState(isEnabled: false)
        }
    }
}

// MARK: - Keyboard Dismissal
extension SignUpNameVC {
    // 화면 터치 시 키패드 내리기 위한 탭 제스처 설정
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // 탭 제스처가 다른 터치 이벤트를 방해하지 않도록 설정
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // 키보드 내리기 메서드
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
