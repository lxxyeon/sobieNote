//
//  HomeTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import Alamofire
import Kingfisher

// TAB1. 홈 화면
class HomeTabViewController: UIViewController, UITextViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataParsing()
        
        TitleStackView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapStackView(sender:)))
        TitleStackView.addGestureRecognizer(tap)
        
        self.goalTextFiled.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    // MARK: - Calendar
    @IBOutlet weak var TitleStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = "\(Global.shared.selectedMonth!)월 소비기록"
        }
    }
    
    let calendarView = CalendarView()
    var calendarIsHidden: Bool = true
    
    // 타이틀스택 클릭시 calendar 보여주는 action
    @objc func didTapStackView (sender: UITapGestureRecognizer) {
        if calendarIsHidden {
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(calendarView)
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: TitleStackView.topAnchor, constant: TitleStackView.frame.height),
                calendarView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                calendarView.heightAnchor.constraint(equalToConstant: self.view.frame.height),
                calendarView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
            ])
            calendarIsHidden = false
        }else{
            calendarView.removeFromSuperview()
            calendarIsHidden = true
        }
    }
    
    // MARK: - Goal TextView
    @IBOutlet weak var goalView: UIView!{
        didSet{
            goalView.layer.cornerRadius = 15
        }
    }
    
    let textViewPlaceHolder = "목표를 적어주세요."
    @IBOutlet weak var goalTextFiled: UITextView!{
        didSet{
            if (UserDefaults.standard.string(forKey: "mission") != nil){
                goalTextFiled.text =  UserDefaults.standard.string(forKey: "mission")
            }else{
                //get api 로 가져온 목표 값
                goalTextFiled.text = textViewPlaceHolder
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if goalTextFiled.text.isEmpty {
            goalTextFiled.text = textViewPlaceHolder
            goalTextFiled.textColor =  UIColor(hexCode: "FFF9CA")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if goalTextFiled.text == textViewPlaceHolder || goalTextFiled.text == " " {
            goalTextFiled.text = nil // 텍스트를 날려줌
            goalTextFiled.textColor =  UIColor(hexCode: "FFF9CA")
        }
    }
    
    /// 목표 전송 API
    @IBAction func sendGoal(_ sender: Any) {
        let newGoal = goalTextFiled.text
        let parameter: Parameters = [
            "mission": newGoal ?? " "
        ]
        
        let request = APIRequest(method: .post,
                                 path: "/goal",
                                 param: parameter,
                                 headers: APIConfig.authHeaders)
        
        APIService.shared.perform(memberId: UserInfo.memberId,
                                  request: request,
                                  completion: { [self] (result) in
            switch result {
            case .success:
                UserDefaults.standard.setValue(newGoal, forKey: "mission")
                var alert = UIAlertController()
                alert = UIAlertController(title:"목표가 저장됐어요!",
                                          message: "",
                                          preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                let buttonLabel = UIAlertAction(title: "확인", style: .default, handler: {_ in
                    self.dismissKeyboard()
                    self.dismiss(animated:true, completion: nil)
                })
                alert.addAction(buttonLabel)
            case .failure:
                print(APIError.networkFailed)
            }
        })
    }
    
    // MARK: - Keyboard Handeling
    // 키보드 올라갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillShow(_ sender:Notification){
        self.view.frame.origin.y = 0
    }
    // 키보드 내려갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillHide(_ sender:Notification){
        self.view.frame.origin.y = 0
    }
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //화면 클릭 인지
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // MARK: - Image CollectionView
    @IBOutlet weak var imgCollectionView: UICollectionView!
    
    var reportImgList = [BoardImage]()
    
    func dataParsing() {
        // 이미지 list GET API
        //        let selectedData = "/2023/12"
        let selectedData = "/" + Global.shared.selectedYear + "/" + Global.shared.selectedMonth
        
        let request = APIRequest(method: .get,
                                 path: "/image" + selectedData,
                                 param: nil,
                                 headers: APIConfig.authHeaders)
        APIService.shared.perform(memberId: UserInfo.memberId,
                                  request: request,
                                  completion: { (result) in
            switch result {
            case .success(let data):
                if let responseDataList = data.body["data"] as? [[String:Any]]{
                    for responseData in responseDataList{
                        let responseBoard = BoardImage(boardId: responseData["boardId"] as! Int,
                                                       imagePath: responseData["imagePath"] as! String)
                        self.reportImgList.append(responseBoard)
                    }
                    self.imgCollectionView.reloadData()
                }
                print(data)
            case .failure:
                print(APIError.networkFailed)
            }
        })
    }
}

// MARK: - CollectionView Handling
// CollectionView Cell data
extension HomeTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reportImgList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        // 역순 정렬
        let reportData = self.reportImgList[self.reportImgList.count - indexPath.row - 1]
        cell.cellImage.contentMode = .scaleAspectFill
        cell.cellImage.kf.setImage(with: URL(string:reportData.imagePath))
        return cell
    }
    
    // refactoring
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reportData = self.reportImgList[self.reportImgList.count - indexPath.row - 1]
        // 상세 화면 이동
        if let uploadViewController = self.storyboard?.instantiateViewController(withIdentifier: "UploadView") as? BoardViewController{
            self.navigationController?.pushViewController(uploadViewController, animated: true)
            uploadViewController.boardId = reportData.boardId
        }
    }
}

// CollectionView FlowLayout
extension HomeTabViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let interval:CGFloat = 0
        let width: CGFloat = ( UIScreen.main.bounds.width - interval * 2 ) / 3 - 1
        return CGSize(width: width , height: width )
    }
    
    // 행 사이 간격
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // 가로 셀 사이 간격
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
