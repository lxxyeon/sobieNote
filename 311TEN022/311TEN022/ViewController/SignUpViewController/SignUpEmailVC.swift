//
//  SignUpEmailVC.swift
//  311TEN022
//
//  Created by leeyeon2 on 4/26/25.
//
import UIKit
import Alamofire

// 회원가입 -  3. 이메일, 강원도 학생 정보 입력 화면
// 회원가입 마지막 단계
// 가입 프로세스
// 1. 일반 가입 : 이메일 인증 후 딥링크로 받은
// 2. 강원도 가입 : 바로 가입 가능

class SignUpEmailVC: UIViewController, UITextFieldDelegate {
    let schoolManager = SchoolManager()
    private var pickerToolbar: UIToolbar?
    
    // 임시 저장
    var userName: String = ""
    var userSchoolName: String = SchoolManager().schools[0].name
    var userAge: String = SchoolManager().schools[0].range[0]
    var userGender: String = "여자"
    
    @IBOutlet weak var subtitleLabel: UILabel!
    // 성별 선택 segment 추가
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBAction func genderSegmentAction(_ sender: Any) {
        if genderSegment.selectedSegmentIndex == 0 {
            userGender = "여자"
        }else{
            userGender = "남자"
        }
        print(userGender)
    }
    
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
            loading3.layer.borderColor = UIColor(hexCode: "B1E7E1").cgColor
            // 테두리 두께 설정
            loading3.layer.borderWidth = 1.0
            // 뷰 내용이 둥근 모서리에 맞게 잘리도록 설정 (선택사항)
            loading3.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var customSwitch: UISwitch!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    // 활성화된 버튼 색상 (청록색)
    private let activeButtonColor = UIColor.Point()
    
    @IBOutlet weak var schoolBtn: UIButton!
    
    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var buttonTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var buttontopConst: NSLayoutConstraint!
    @IBOutlet weak var pickerBottomContstraint: NSLayoutConstraint!
    
    // 비활성화된 버튼 색상 (회색)
    private let inactiveButtonColor = UIColor.systemGray6
    private var isPickerVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // picker init setting
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerBottomContstraint.constant = -170
        schoolBtn.layer.cornerRadius = 5
        schoolBtn.layer.borderColor = UIColor.systemGray6.cgColor
        // 테두리 두께 설정
        schoolBtn.layer.borderWidth = 0.5
        
        // 초기 가입 버튼 설정
        setupNextButton()
        customSwitch.isOn = false
        self.buttonTopConstraint.constant = -130
        setupSchoolButtonUI()
        
        // 초기에 강원도 뷰 숨김
        customView.isHidden = true
        customSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        // 텍스트 필드 delegate 설정
        emailTextField.delegate = self
        nameTextField.delegate = self // nameTextField delegate 추가
        
        // 텍스트 변경 이벤트 추가
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) // nameTextField 이벤트 추가
        
        // 화면 터치 시 키패드 내리기 위한 탭 제스처 추가
        setupTapGesture()
        emailTextField.clearButtonMode = .always
        nameTextField.clearButtonMode = .always
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tapGesture)
        setupPickerToolbar()
    }
    
    private func setupSchoolButtonUI() {
        var config = UIButton.Configuration.plain()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14)
            return outgoing
        }
        
        schoolBtn.configuration? = config
        schoolBtn.configuration?.baseForegroundColor = UIColor.systemGray2
        schoolBtn.setTitle("소속/학년", for: .normal)
        
        schoolBtn.layer.cornerRadius = 5
        nameTextField.layer.borderColor = UIColor.systemGray2.cgColor
        nameTextField.font = UIFont.systemFont(ofSize: 14)
        //        schoolBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        schoolBtn.layer.borderColor = UIColor.systemGray2.cgColor
        schoolBtn.layer.borderWidth = 0.3
        
        schoolBtn.contentHorizontalAlignment = .left
        schoolBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: nameTextField.frame.height))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        
    }
    // 버튼 초기 설정
    private func setupNextButton() {
        // 초기 상태는 비활성화
        updateButtonState(isEnabled: false)
    }
    
    // 강원도 토글 변경시 하단 뷰 숨김/보임
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        customView.isHidden = !sender.isOn
        subtitleLabel.isHidden = sender.isOn
        
        if sender.isOn {
            self.buttonTopConstraint.constant = 10
            //
            //            var config = UIButton.Configuration.plain()
            //            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            //                var outgoing = incoming
            //                outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            //                return outgoing
            //            }
            nextBtn.configuration?.baseBackgroundColor = activeButtonColor
            nextBtn.configuration?.baseForegroundColor = UIColor.white
            nextBtn.setTitle("가입하기", for: .normal)
            //            nextBtn.configuration? = config
            
        }else{
            // pickerview 열려 있는 경우 닫기
            if isPickerVisible{
                togglePickerView()
            }

//            if !pickerToolbar!.isHidden {
//                self.pickerBottomContstraint.constant = -170
//                self.pickerToolbar?.isHidden = true
//            }

            self.buttonTopConstraint.constant = -130
            nextBtn.setTitle("인증하기", for: .normal)
        }
    }
    
    @IBAction func signUpBtn(_ sender: Any) {
        // 회원가입 api
        // 옵셔널 값 없으면 이메일 인증 후 로그인 화면
        // 있으면 이메일 인증 없음 바루 홈화면
        //        let parameter: Parameters = [
        //            "name": UserSignupModel.shared.nickName,
        //            "email": UserSignupModel.shared.email,
        //            "password": UserSignupModel.shared.password
        //        ]
        
        //        let parameter: Parameters = [
        //            "name": UserSignupModel.shared.nickName,
        //            "email": UserSignupModel.shared.email,
        //            "password": UserSignupModel.shared.password,
        //            "schoolName": "",
        //            "age": "",
        //            "studentName": ""
        //        ]
        
        //test data

        
        // customSwitch 값에 따른 분기처리 수행
        if customSwitch.isOn {
            userName = nameTextField.text ?? ""
            // 강원도 학생 로그인 - 이메일 인증 불필요
            if userName.count > 0 {
                
                let parameter: Parameters = [
                    "name": UserSignupModel.shared.nickName,
                    "email": emailTextField.text ?? "",
                    "password": UserSignupModel.shared.password,
                    "schoolName": userSchoolName,
                    "age": getCurrentUserAge() ?? "",
                    "studentName": userName,
                    "gender": userGender
                ]
                
                let request = APIRequest(method: .post,
                                         path: "/member/signup",
                                         param: parameter,
                                         headers: APIConfig.headers)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
                    switch result {
                    case .success(let data):
                        // 1. 회원정보 저장
                        if let responseData = data.body["data"] as? [String:Any] {
                            UserInfo.token = responseData["accessToken"] as! String
                            UserInfo.memberId = "\(responseData["memberId"] as! Int)"
                            UserInfo.nickName = UserSignupModel.shared.nickName
                            UserInfo.age = getCurrentUserAge() ?? ""
                            UserInfo.email = emailTextField.text ?? ""
                            UserInfo.studentName = userName
                            UserInfo.schoolName = userSchoolName
                            UserInfo.gender = userGender
                            UserInfo.saveUserInfo(type: 1)
//                            UserDefaults.standard.setValue(res, forKey: "memberId")
//                            UserDefaults.standard.setValue(email, forKey: "email")
//                            UserDefaults.standard.setValue(name, forKey: "name")
//                            UserDefaults.standard.setValue(res, forKey: "memberId")
//                            UserDefaults.standard.setValue(email, forKey: "email")
//                            UserDefaults.standard.setValue(name, forKey: "name")
//                            UserDefaults.standard.setValue(name, forKey: "name")
                            
                            AlertView.showAlert(title: "회원가입이 완료되었습니다. 😊",
                                               message: "소비채집을 시작해보세요.",
                                               viewController: self)
                            {
                                // 2. 화면 이동
                                UIViewController.changeRootVCToHomeTab()
                            }
                        }else{
                            // 에러처리
                            if let errorData = data.body["error"] as? [String:Any]{
                                if let code = errorData["code"] as? Int {
                                    switch code {
                                        case 409:
                                        AlertView.showAlert(title: "가입에 실패했습니다.",
                                                            message: "중복된 회원입니다.",
                                                            viewController: self,
                                                            dismissAction: nil)
                                    default:
                                        AlertView.showAlert(title: "가입에 실패했습니다.",
                                                            message: "",
                                                            viewController: self,
                                                            dismissAction: nil)
                                    }
                                }
                            }
                        }
                    case .failure:
                        print(APIError.networkFailed)
                    }
                })
            }else{
                // 학생 이름 입력 해야 함
                AlertView.showAlert(title: "이름을 입력해주세요. 😊",
                                    message: "",
                                    viewController: self,
                                    dismissAction: nil)
            }
        }else{
            // 일반 자체 로그인 - 이메일 인증 필요
            let parameter: Parameters = [
                "name": UserSignupModel.shared.nickName,
                "email": emailTextField.text ?? "",
                "password": UserSignupModel.shared.password,
                "schoolName": "",
                "age": "",
                "studentName": ""
            ]
            
            let request = APIRequest(method: .post,
                                     path: "/member/signup",
                                     param: parameter,
                                     headers: APIConfig.headers)
            APIService.shared.perform(request: request,
                                      completion: { [self] (result) in
                switch result {
                case .success:
                    print("가입 성공")
                    // 가입 성공
                    //alert
                    AlertView.showAlert(title: "인증 메일을 전송하였습니다.",
                                        message: "메일을 확인하여 인증을 완료해주세요.",
                                        viewController: self,
                                        dismissAction: nil)
                case .failure:
                    print(APIError.networkFailed)
                }
            })
        }
    }
    
    // 소속/나이 버튼 클릭 시 토글 오픈
    @IBAction func showPicker(_ sender: Any) {
        togglePickerView()
    }
    
    // pickerView 관련 설정 아래에 추가
    private func setupPickerToolbar() {
        // 툴바 생성
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.Point()
        toolBar.sizeToFit()
        
        // 툴바에 버튼 추가
        let doneButton = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(donePickerTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelPickerTapped))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        // toolBar.barTintColor = UIColor.red
        // 메인 뷰에 툴바 추가 (pickerView에 추가하지 말고)
        view.addSubview(toolBar)
        
        // 툴바 위치 설정 - pickerView 바로 위에 배치
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.bottomAnchor.constraint(equalTo: pickerView.topAnchor, constant: 40),
            toolBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 툴바를 프로퍼티로 저장해서 나중에 숨기기/보이기 제어
        self.pickerToolbar = toolBar
        
        // 초기에는 툴바 숨김
        toolBar.isHidden = true
    }
    
    // 확인 버튼 탭 이벤트 처리
    @objc private func donePickerTapped() {
        // 선택한 값 버튼에 적용
        let cityIdx = pickerView.selectedRow(inComponent: 0)
        let selectedSchool = schoolManager.schools[cityIdx].name
        let tourIdx = pickerView.selectedRow(inComponent: 1)
        let selectedTourAttraction = schoolManager.schools[cityIdx].range[tourIdx]
        
        schoolBtn.setTitle("\(selectedSchool) / \(selectedTourAttraction)", for: .normal)
        schoolBtn.setTitleColor(UIColor.black, for: .normal)
        
        schoolBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        // 피커 닫기
        togglePickerView()
    }
    
    // 취소 버튼 탭 이벤트 처리
    @objc private func cancelPickerTapped() {
        // 피커 닫기 (값 적용 없이)
        togglePickerView()
    }
    
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // 이메일 필드 검증
        if textField == emailTextField {
            if let text = textField.text, !text.isEmpty, isValidEmail(text) {
                updateButtonState(isEnabled: true)
            } else {
                updateButtonState(isEnabled: false)
            }
        }
        // nameTextField에 대한 추가 검증 로직이 필요하다면 여기에 추가
    }
    
    // 이메일 형식 검증 함수 추가
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // 버튼 상태 업데이트 함수
    private func updateButtonState(isEnabled: Bool) {
        nextBtn.isEnabled = isEnabled
        if isEnabled {
            // 활성화 상태: 청록색
            nextBtn.configuration?.baseBackgroundColor = activeButtonColor
            nextBtn.configuration?.baseForegroundColor = UIColor.white
            //            var config = UIButton.Configuration.plain()
            //            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            //                var outgoing = incoming
            //                outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            //                return outgoing
            //            }
            //
            if customSwitch.isOn {
                nextBtn.setTitle("가입하기", for: .normal)
                
            }else{
                nextBtn.setTitle("인증하기", for: .normal)
            }
           
            //            nextBtn.configuration? = config
        } else {
            // 비활성화 상태: 회색
            //            nextBtn.backgroundColor = inactiveButtonColor
        }
    }
    
    // 피커뷰 보이기/없애기
    private func togglePickerView() {

        isPickerVisible = !isPickerVisible
        UIView.animate(withDuration: 0.3) {
            if self.isPickerVisible {
                // 피커뷰와 툴바 표시
                self.pickerBottomContstraint.constant = 0
                self.pickerToolbar?.isHidden = false
            } else {
                // 피커뷰와 툴바 숨김
                self.pickerBottomContstraint.constant = -170
                self.pickerToolbar?.isHidden = true
//                self.nextBtn.setTitle("인증하기", for: .normal)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissPicker() {
        if isPickerVisible {
            // 선택한 값 버튼에 적용
            let cityIdx = pickerView.selectedRow(inComponent: 0)
            let selectedSchool = schoolManager.schools[cityIdx].name
            let tourIdx = pickerView.selectedRow(inComponent: 1)
            let selectedTourAttraction = schoolManager.schools[cityIdx].range[tourIdx]
            
            schoolBtn.setTitle("\(selectedSchool) \(selectedTourAttraction)", for: .normal)
            schoolBtn.setTitleColor(UIColor.black, for: .normal)
            schoolBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            // 피커 닫기
            togglePickerView()
        }
        // 키보드도 함께 내리기
        view.endEditing(true)
    }
}

// MARK: - UIPickerViewDataSource
extension SignUpEmailVC:  UIPickerViewDelegate, UIPickerViewDataSource {
    // pickerview 가로 사이즈 설정
    // 나중에 리스트 받고 수정하기
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let totalWidth = pickerView.frame.width
        if component == 0 {
            return 250
        } else {
            return 100
        }
    }
    
    // pickerview 폰트 사이즈, 정렬 설정
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        // 폰트 설정 (14pt)
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = UIColor.black
        
        // 텍스트 설정
        if component == 0 {
            // 첫 번째 컴포넌트 (학교명)
            if row < schoolManager.schools.count {
                label.text = schoolManager.schools[row].name
            }
        } else {
            // 두 번째 컴포넌트 (학년/나이)
            let selectedSchool = pickerView.selectedRow(inComponent: 0)
            if selectedSchool < schoolManager.schools.count &&
               row < schoolManager.schools[selectedSchool].range.count {
                label.text = schoolManager.schools[selectedSchool].range[row]
            }
        }
        
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return schoolManager.schools.count
        } else {
            // 0번 컴포넌트에서 선택된 행의 인덱스
            let selectedSchool = pickerView.selectedRow(inComponent: 0)
            return schoolManager.schools[selectedSchool].range.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 0번째 컴포넌트의 행에는 도시 이름이 나오고,
        if component == 0 {
            return schoolManager.schools[row].name
        } else {
            // 나머지 컴포넌트의 행에는 0번째 컴포넌트에서 선택한 도시에 대한
            // tourAttractions 배열의 값들이 나온다.
            let selectedSchool = pickerView.selectedRow(inComponent: 0)
            return schoolManager.schools[selectedSchool].range[row]
        }
    }
    // 피커뷰의 스크롤을 움직여서 값이 선택되었을 때 호출되는 메소드.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            // 특정 컴포넌트의 행을 선택하게 하는 메소드이다.
            // 그러므로 아래는 1번째 컴포넌트의 0번째 줄을 선택하게 된다.
            pickerView.selectRow(0, inComponent: 1, animated: false)
        }
        
        // 선택한 값을 레이블이 보여주는 부분
        let cityIdx = pickerView.selectedRow(inComponent: 0)
        let selectedSchool = schoolManager.schools[cityIdx].name
        userSchoolName = selectedSchool
        
        let tourIdx = pickerView.selectedRow(inComponent: 1)
        let selectedTourAttraction = schoolManager.schools[cityIdx].range[tourIdx]
        userAge = selectedTourAttraction
        //        pickerResultLabel.text = "\(selectedTourAttraction), \(selectedSchool)"
        
        // 16번째 줄과 같이 0번째 컴포넌트에서 변화가 감지되었다는 것은
        // 1번째 컴포넌트에 보여주어야 할 데이터가 달라졌다는 것이므로
        // reloadComponent 메소드를 사용하여 1번째 컴포넌트를 업데이트 한다.
        pickerView.reloadComponent(1)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpEmailVC {
    // Return 키를 누를 때 키보드 내리기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            // 이메일 입력 후 nameTextField로 포커스 이동 (강원도 학생 정보가 표시된 경우)
            if !customView.isHidden {
                nameTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else if textField == nameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Keyboard Dismissal
extension SignUpEmailVC {
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
    
    // 소속에 따른 age transfer
    func getCurrentUserAge() -> String? {
        return schoolManager.convertToAge(schoolName: userSchoolName, gradeOrAge: userAge)
    }
    
    // 파라미터 검증 및 나이 변환
    func validParameter(param: Parameters) -> Parameters? {
        var validatedParam = param
        
        // 학년을 나이로 변환
        if let ageString = getCurrentUserAge() {
            validatedParam["age"] = ageString
            return validatedParam
        }
        
        return nil
    }
}
