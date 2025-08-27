//
//  SettingViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 2/10/24.
//

import UIKit

// MARK: - 설정 화면
class SettingViewController: UIViewController{
    
    @IBOutlet weak var settingTableView: UITableView!
    
    let SettingMenues = ["사용자 정보", "로그아웃", "탈퇴하기", "앱 버전 정보"]
    let SettingImgs = ["person.fill",
                       "rectangle.portrait.and.arrow.right",
                       "person.crop.circle.badge.minus",
                       "clock.arrow.trianglehead.counterclockwise.rotate.90"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.separatorStyle = .none
        navigationController?.setNavigationBarHidden(false, animated: true)
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func deleteAccountMenu() {
        //UserInfo init
        UserInfo.init()
        
        //Userdefalut 삭제
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        //로그인 화면 이동
        UIViewController.changeRootVCToSignIn()
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate, AlertPresentable {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingMenues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingTableViewCell
        cell.selectionStyle = .none
        cell.titleLabel.text = SettingMenues[indexPath.row]
        cell.titleLabel.font = UIFont.kimR17()
        cell.versionLabel?.text = ""
        
        // 버전 정보 셀인 경우 버전을 표시
        if indexPath.row == 3 {
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "버전 정보 없음"
            cell.versionLabel?.text = appVersion
            cell.versionLabel?.font = UIFont.kimR17()
        }
        
        if let imageView = cell.settingImg {
            imageView.image = UIImage(systemName: SettingImgs[indexPath.row])
            imageView.tintColor = .systemGray
        }
        
        if indexPath.row == 0 {
            // 화살표 추가
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var alert = UIAlertController()
        // 사용자 정보
        if indexPath.row == 0 {
            // 화면전환버튼
            guard let nextVC = self.storyboard?.instantiateViewController(identifier: "SettingInfo") else {return}
            self.navigationController?.pushViewController(nextVC, animated: true)
            
        }
        else if indexPath.row == 1 {
            // 로그아웃
            alert = UIAlertController(title:"로그아웃 하시겠습니까?",
                                      message: "로그인 화면으로 이동합니다.",
                                      preferredStyle: UIAlertController.Style.alert)
            self.present(alert,animated: true,completion: nil)
            
            let actionConfirm = UIAlertAction(title: "확인", style: .default, handler: {_ in
                // 화면 이동 및 UserDefaults 초기화
                AlertView.showAlert(title: "로그아웃이 완료되었습니다.",
                                    message: "로그인 화면으로 이동합니다.",
                                    viewController: self,
                                    dismissAction: self.deleteAccountMenu)
            })
            let actionCancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            
            alert.addAction(actionConfirm)
            alert.addAction(actionCancel)
        }
        else if indexPath.row == 2{
            // 회원 탈퇴 - 계정 삭제 api 수행
            alert = UIAlertController(title:"회원 탈퇴하시겠습니까?",
                                      message: "지난 소비기록이 모두 사라집니다.",
                                      preferredStyle: UIAlertController.Style.alert)
            self.present(alert,animated: true,completion: nil)
            
            let actionConfirm = UIAlertAction(title: "확인", style: .default, handler: {_ in
                let request = APIRequest(method: .delete,
                                         path: "/member" + "/\(UserInfo.memberId)",
                                         param: nil,
                                         headers: APIConfig.authHeaders)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
                    //                    showAlert(title: <#T##String#>, message: <#T##String#>)
                    
                    AlertView.showAlert(title: "회원 탈퇴가 완료되었습니다.",
                                        message: "로그인 화면으로 이동합니다.",
                                        viewController: self,
                                        dismissAction: self.deleteAccountMenu)
                })
            })
            let actionCancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            
            alert.addAction(actionConfirm)
            alert.addAction(actionCancel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
