//
//  SettingInfoViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 4/30/25.
//

import UIKit
import Alamofire

class SettingInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let schoolManager = SchoolManager()
    var userName: String = ""
    var userSchoolName: String = SchoolManager().schools[0].name
    var userAge: String = SchoolManager().schools[0].range[0]
    
    private var pickerToolbar: UIToolbar?
    private var isPickerVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationBar 세팅
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.kimB19()]
        self.navigationItem.title = "사용자 정보"
        
        // default image
        userImg.image = UIImage(named: "1024")
        userImg.layer.cornerRadius = userImg.frame.width / 2
        userImg.clipsToBounds = true
        userImg.contentMode = .scaleAspectFit
        
        // 테이블뷰 setting
        userInfoTableView.delegate = self
        userInfoTableView.dataSource = self
        userOptionalTableView.delegate = self
        userOptionalTableView.dataSource = self
        
        userInfoTableView.isScrollEnabled = false
        userOptionalTableView.isScrollEnabled = false
        
        userInfoTableView.layer.cornerRadius = 15
        userInfoTableView.clipsToBounds = true
        
        userOptionalTableView.layer.cornerRadius = 15
        userOptionalTableView.clipsToBounds = true
        
        userInfoTableView.layer.borderWidth = 1
        userInfoTableView.layer.borderColor = UIColor.systemGray5.cgColor
        userInfoTableView.separatorStyle = .singleLine
        userInfoTableView.separatorColor = UIColor.systemGray2
        userInfoTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        userOptionalTableView.layer.borderWidth = 1
        userOptionalTableView.layer.borderColor = UIColor.systemGray5.cgColor
        userOptionalTableView.separatorStyle = .singleLine
        userOptionalTableView.separatorColor = UIColor.systemGray2
        userOptionalTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        // pickerView setting
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 키패드 제어
        setupTapGesture()
        
        checkAndSetInitialState()
        
        
        // 강원도 정보 입력창 출력
        customSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        //        view.addGestureRecognizer(tapGesture)
        setupPickerToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAndSetInitialState()
    }
    
    private func checkAndSetInitialState() {
        if !UserInfo.schoolName.isEmpty && UserInfo.schoolName != "" {
            setOptionTableView(type: 1) // 강원도 학생
        } else {
            setOptionTableView(type: 0) // 일반 참가자
        }
    }
    
    func setOptionTableView(type: Int) {
        pickerView.isHidden = true
        if type == 0 {
            // 일반 참가자
            customSwitch.isOn = false
            userOptionalTableView.isHidden = true
            modifyBtn.isHidden = true
        }else{
            // 강원도 참가자
            customSwitch.isOn = true
            userOptionalTableView.isHidden = false
            modifyBtn.isHidden = false
        }
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
        
        // ✅ UserInfo에도 저장 (필요시)
        UserInfo.schoolName = userSchoolName
        UserInfo.age = userAge
        
        // 배열도 함께 업데이트
        userOptionalDataValue[1] = userSchoolName
        userOptionalDataValue[2] = userAge
        
        // ✅ 테이블뷰 리로드해서 변경된 값 표시
        DispatchQueue.main.async {
            self.userOptionalTableView.reloadData()
        }
    }
    
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
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var userInfoTableView: UITableView!
    @IBOutlet weak var userOptionalTableView: UITableView!
    
    @IBOutlet weak var customSwitch: UISwitch!
    
    @IBOutlet weak var modifyBtn: UIButton!{
        didSet{
            setupModifyButtonStyle()
        }
    }
    
    private func setupModifyButtonStyle() {
        modifyBtn.configuration = nil
        modifyBtn.setTitle("수정하기", for: .normal)
  
        modifyBtn.setTitleColor(.white, for: .normal)
        modifyBtn.setTitleColor(.white, for: .highlighted)
        modifyBtn.setTitleColor(.white, for: .selected)
        modifyBtn.setTitleColor(.white, for: .disabled)
        modifyBtn.titleLabel?.font = UIFont.kimB18()
        // 추가적인 스타일 설정
        modifyBtn.layer.cornerRadius = 8
        modifyBtn.backgroundColor = UIColor.Point() // 또는 원하는 색상
        
        modifyBtn.setNeedsDisplay()
        modifyBtn.layoutIfNeeded()
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    // 테이블뷰에 표시할 데이터 배열 추가
    let userInfoData = ["닉네임", "이메일"]
    let userOptionalInfoData = ["이름", "소속", "나이"]
    
    // dummy data
    //    let userInfoDummyData = ["이용", "lxxyeon@naver.com"]
    //    let userOptionalInfoDummyData = ["안이연", "12", "강원초등학교"]
    
    var userInfoDataValue = [UserInfo.nickName, UserInfo.email]
    var userOptionalDataValue = [UserInfo.studentName, UserInfo.schoolName, UserInfo.age]
    
    
    
    @objc private func dismissPicker() {
        if isPickerVisible {
            // 선택한 값 버튼에 적용
            let cityIdx = pickerView.selectedRow(inComponent: 0)
            let selectedSchool = schoolManager.schools[cityIdx].name
            let tourIdx = pickerView.selectedRow(inComponent: 1)
            let selectedTourAttraction = schoolManager.schools[cityIdx].range[tourIdx]
            
            // 피커 닫기
            togglePickerView()
        }
        // 키보드도 함께 내리기
        dismissKeyboard()
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
            toolBar.bottomAnchor.constraint(equalTo: pickerView.topAnchor, constant: 20),
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
        
        // 피커 닫기
        togglePickerView()
        self.modifyBtn.isHidden = false
    }
    
    // 취소 버튼 탭 이벤트 처리
    @objc private func cancelPickerTapped() {
        // 피커 닫기 (값 적용 없이)
        togglePickerView()
        self.modifyBtn.isHidden = false
    }
    
    private func togglePickerView() {
        isPickerVisible = !isPickerVisible
        UIView.animate(withDuration: 0.3) {
            if self.isPickerVisible {
                // 피커뷰와 툴바 표시
                self.pickerToolbar?.isHidden = false
                self.pickerView.isHidden = false
            } else {
                self.pickerView.isHidden = true
                self.pickerToolbar?.isHidden = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // 강원도 정보 입력창 출력
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        userOptionalTableView.isHidden = !sender.isOn
        modifyBtn.isHidden = !sender.isOn
        
        if sender.isOn {
            
        }else{
            
        }
    }
    
    // 강원도 청소년활동진흥센터 청소년 정보 추가 API
    @IBAction func modifyAction(_ sender: Any) {
        // 입력값 검증
        guard !UserInfo.studentName.isEmpty else {
            AlertView.showAlert(title: "이름을 입력해주세요.",
                               message: "",
                               viewController: self,
                               dismissAction: nil)
            return
        }
        
        guard !UserInfo.schoolName.isEmpty else {
            AlertView.showAlert(title: "소속을 선택해주세요.",
                               message: "",
                               viewController: self,
                               dismissAction: nil)
            return
        }
        
        guard !UserInfo.age.isEmpty else {
            AlertView.showAlert(title: "나이를 선택해주세요.",
                               message: "",
                               viewController: self,
                               dismissAction: nil)
            return
        }

        var modifyStudentUrl = "/member/student" + "/\(UserInfo.memberId)"
        
        let parameter: Parameters = [
            "schoolName": UserInfo.schoolName,
            "age": Int(SchoolManager().convertToAge(schoolName: UserInfo.schoolName, gradeOrAge: UserInfo.age)
                      ?? "")!,
            "studentName": UserInfo.studentName,
        ]
        
        let request = APIRequest(method: .patch,
                                 path: modifyStudentUrl,
                                 param: parameter,
                                 headers: APIConfig.authHeaders)
        
        APIService.shared.perform(request: request) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        // 성공 시 UserInfo 저장 및 UI 업데이트
                        UserInfo.saveUserInfo(type: 1) // 강원도 학생으로 저장
                        
                        AlertView.showAlert(title: "정보가 성공적으로 업데이트되었습니다.",
                                           message: "",
                                           viewController: self!,
                                           dismissAction: {
                            // 성공 후 UI 업데이트
                            self?.checkAndSetInitialState()
                            self?.userOptionalTableView.reloadData()
                        })
                    case .failure(let error):
                        AlertView.showAlert(title: "업데이트에 실패했습니다.",
                                           message: "다시 시도해주세요.",
                                           viewController: self!,
                                           dismissAction: nil)
                    }
                }
            }
    }
    
    // 기존 UITextFieldDelegate 메서드에 추가
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 편집이 끝났을 때 UserInfo에 저장
        if let cell = textField.superview?.superview as? UserOptionalTextFieldCell {
            UserInfo.studentName = textField.text ?? ""
        }
    }
}

extension SettingInfoViewController: UITableViewDataSource, UITableViewDelegate {
    // 테이블 뷰 셀 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ✅ 셀 선택 해제 추가
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == userOptionalTableView {
            if indexPath.row == 0 {
                return
            }else if indexPath.row == 1 || indexPath.row == 2 {
                pickerView.isHidden = false
                modifyBtn.isHidden = true
                togglePickerView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 어떤 테이블뷰인지 구분하여 다른 개수 반환
        if tableView == userInfoTableView {
            return userInfoData.count // 2개 반환
        } else if tableView == userOptionalTableView {
            return userOptionalInfoData.count // 3개 반환
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 테이블뷰에 따라 다른 셀 반환
        if tableView == userInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.titleLabel.text = userInfoData[indexPath.row]
            cell.valueLabel.text = userInfoDataValue[indexPath.row]
            cell.titleLabel.font = UIFont.kimR17()
            cell.valueLabel.font = UIFont.kimR17()
            // 닉네임 변경
            //            if indexPath.row == 0 {
            //                // 화살표 추가
            //                cell.accessoryType = .disclosureIndicator
            //            }
            
            // 여기에 추가 설정 (값 표시 등)
            cell.selectionStyle = .none
            return cell
            // 강원도 학생인 경우
        } else if tableView == userOptionalTableView {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserOptionalTextFieldCell", for: indexPath) as! UserOptionalTextFieldCell
                cell.titleLabel.text = userOptionalInfoData[indexPath.row]
                cell.titleLabel.font = UIFont.kimR17()
                cell.textField.text = UserInfo.studentName
                
                // 텍스트필드 이벤트 추가
                cell.textField.addTarget(self, action: #selector(nameTextFieldChanged(_:)), for: .editingChanged)
                cell.textField.delegate = self
                
                cell.selectionStyle = .none
                return cell
            } else {
                // 나머지 셀은 기존대로 Label 셀 사용
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserOptionalInfoCell", for: indexPath) as! UserOptionalInfoCell
                cell.titleLabel.text = userOptionalInfoData[indexPath.row]
                cell.titleLabel.font = UIFont.kimR17()
                cell.valueLabel.font = UIFont.kimR17()
                
                // 직접 UserInfo에서 최신 값을 가져오기
                switch indexPath.row {
                case 1:
                    cell.valueLabel.text = UserInfo.schoolName
                case 2:
                    cell.valueLabel.text = UserInfo.age
                default:
                    cell.valueLabel.text = ""
                }
                
                return cell
            }
        }
        return UITableViewCell() // 기본 셀 반환 (이 경우에는 실행되지 않음)
    }
    
    // 선택적: 셀 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // 모든 셀의 높이를 60으로 설정
    }
    
    @objc private func nameTextFieldChanged(_ textField: UITextField) {
        // UserInfo에 실시간으로 저장
        UserInfo.studentName = textField.text ?? ""
        print("이름 변경됨: \(UserInfo.studentName)")
    }
}


class UserInfoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

class UserOptionalInfoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

// 기존 UserOptionalInfoCell 클래스 아래에 추가
class UserOptionalTextFieldCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextField()
    }
    
    private func setupTextField() {
        textField.borderStyle = .none
        textField.font = UIFont.kimR17()
        textField.placeholder = "이름"
        textField.clearButtonMode = .whileEditing
        
        // 텍스트필드 패딩 추가
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
}

// MARK: - Keyboard Dismissal
// SettingInfoViewController 클래스 내부에 추가할 메서드들
extension SettingInfoViewController {
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
