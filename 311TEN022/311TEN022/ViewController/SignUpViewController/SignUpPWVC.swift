//
//  SignUpPWVC.swift
//  311TEN022
//
//  Created by leeyeon2 on 4/26/25.
//

import UIKit

// 회원가입 -  2. 패쓰워드 입력 화면
class SignUpPWVC: UIViewController, UITextFieldDelegate {
    
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
            loading2.layer.borderColor = UIColor(hexCode: "B1E7E1").cgColor
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
    
    @IBOutlet weak var subTitle: UILabel!{
        didSet{
            subTitle.numberOfLines = 0
        }
    }
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var pw1TextField: UITextField!
    
    @IBOutlet weak var pw2TextField: UITextField!
    
    // 활성화된 버튼 색상 (청록색)
    private let activeButtonColor = UIColor.Point()
    
    // 비활성화된 버튼 색상 (회색)
    private let inactiveButtonColor = UIColor.systemGray6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 초기 버튼 설정
        setupNextButton()
        // 텍스트 필드 delegate 설정
        pw1TextField.delegate = self
        pw2TextField.delegate = self
        // 텍스트 변경 이벤트 추가
        pw1TextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        pw2TextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // 화면 터치 시 키패드 내리기 위한 탭 제스처 추가
        setupTapGesture()
        
        pw1TextField.clearButtonMode = .always
        pw2TextField.clearButtonMode = .always
        
        // 비밀번호 입력 필드로 설정
        pw1TextField.isSecureTextEntry = true
        pw2TextField.isSecureTextEntry = true
        
        // 비밀번호 입력값 보이게
        setupPasswordToggle()
    }
    
    // 회원가입 정보 전달 - 비밀번호
    @IBAction func nextBtnAction(_ sender: Any) {
        UserSignupModel.shared.password = pw2TextField.text ?? ""
    }
    
    // 버튼 초기 설정
    private func setupNextButton() {
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
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        validatePasswordFields()
    }
    
    // 비밀번호 유효성 검사 함수
    private func validatePasswordFields() {
        guard let password1 = pw1TextField.text, let password2 = pw2TextField.text else {
            updateButtonState(isEnabled: false)
            return
        }
        // 비밀번호가 일치하는지 확인
        let passwordsMatch = password1 == password2
        
        // 비밀번호 형식이 유효한지 확인 (영어, 숫자, 특수문자 포함 8~10자)
        let isValidFormat = isValidPassword(password1)
        
        // 두 조건을 모두 만족하면 버튼 활성화
        let shouldEnableButton = passwordsMatch && isValidFormat && !password1.isEmpty && !password2.isEmpty
        
        updateButtonState(isEnabled: shouldEnableButton)
    }
    
    // 비밀번호 형식 검사 함수 (영어, 숫자, 특수문자 포함 8~10자)
    private func isValidPassword(_ password: String) -> Bool {
        // 길이 확인 (8~10자)
        guard password.count >= 8 && password.count <= 10 else {
            return false
        }
        
        // 영문자 포함 여부
        let alphabetRegex = ".*[A-Za-z].*"
        let alphabetPredicate = NSPredicate(format: "SELF MATCHES %@", alphabetRegex)
        guard alphabetPredicate.evaluate(with: password) else {
            return false
        }
        
        // 숫자 포함 여부
        let digitRegex = ".*[0-9].*"
        let digitPredicate = NSPredicate(format: "SELF MATCHES %@", digitRegex)
        guard digitPredicate.evaluate(with: password) else {
            return false
        }
        
        // 특수문자 포함 여부
        let specialCharRegex = ".*[!@#$%^&*(),.?\":{}|<>].*"
        let specialCharPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharRegex)
        guard specialCharPredicate.evaluate(with: password) else {
            return false
        }
        
        // 모든 조건 만족
        return true
    }
}

// MARK: - Keyboard Dismissal
extension SignUpPWVC {
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
    
    
    // TextField에 비밀번호 토글 버튼 추가하는 함수
    func setupPasswordToggle() {
        // 첫 번째 비밀번호 필드에 토글 버튼 추가
        addPasswordToggleButton(to: pw1TextField)
        
        // 두 번째 비밀번호 필드에 토글 버튼 추가
        addPasswordToggleButton(to: pw2TextField)
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
        if textField == pw1TextField {
            toggleButton.tag = 1
        } else if textField == pw2TextField {
            toggleButton.tag = 2
        }
    }
    
    // 비밀번호 표시/숨김 토글 액션
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        // 버튼 태그로 어떤 텍스트필드의 버튼인지 확인
        let textField: UITextField
        if sender.tag == 1 {
            textField = pw1TextField
        } else {
            textField = pw2TextField
        }
        
        // 비밀번호 표시 상태 전환
        textField.isSecureTextEntry.toggle()
        
        // 버튼 아이콘 변경
        if textField.isSecureTextEntry {
            sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
}
