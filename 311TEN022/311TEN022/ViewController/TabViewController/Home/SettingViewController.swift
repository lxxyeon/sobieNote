//
//  SettingViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 2/10/24.
//

import UIKit

// MARK: - 설정 화면
class SettingViewController: UIViewController {
    
    let SettingMenues = ["닉네임", "이메일계정", "탈퇴하기"]
    let SettingValues = [UserInfo.name, UserInfo.email, ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
                let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = backBarButtonItem
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func deleteAccountMenu() {
        //UserInfo init
        UserInfo.token = ""
        
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
        cell.valueLabel.text = SettingValues[indexPath.row]
        cell.valueLabel.font = UIFont.kimR17()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{
            //회원 탈퇴
            var alert = UIAlertController()
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
