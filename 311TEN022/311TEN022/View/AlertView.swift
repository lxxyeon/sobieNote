//
//  AlertView.swift
//  311TEN022
//
//  Created by leeyeon2 on 1/11/24.
//

import UIKit

class AlertView {
    
    /// 확인 alert 메시지 띄우는 메소드
    /// - Parameters:
    ///   - title: 제목
    ///   - message: 설명
    ///   - viewController: present view
    ///   - dismissAction: dismiss 수행 후 수행될 메소드
    static func showAlert(title: String,
                          message: String?,
                          viewController: UIViewController,
                          dismissAction: (() -> Void)?) {
        let alert = UIAlertController(title: title,
                                  message: message ?? "",
                                  preferredStyle: UIAlertController.Style.alert)
        viewController.present(alert,
                               animated: true,
                               completion: nil)
        
        let buttonLabel = UIAlertAction(title: "확인",
                                        style: .default,
                                        handler: {_ in
            if let dismissAction = dismissAction {
                dismissAction()
            }
            viewController.dismiss(animated:true, completion: nil)
        })
        alert.addAction(buttonLabel)
    }
}
