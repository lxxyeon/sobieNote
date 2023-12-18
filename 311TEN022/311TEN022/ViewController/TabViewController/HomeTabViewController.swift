//
//  HomeTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import Alamofire

// TAB1. 메인 화면
class HomeTabViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var TitleStackView: UIStackView!
    //

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
        //        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        //
        //        flowLayout.minimumInteritemSpacing = margin
        //        flowLayout.minimumLineSpacing = margin
        //        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
    }
    
    
    
    let margin: CGFloat = 0
    let textViewPlaceHolder = "목표를 적어주세요."
    func textViewDidEndEditing(_ textView: UITextView) {
        if goalTextFiled.text.isEmpty {
            goalTextFiled.text = textViewPlaceHolder
            goalTextFiled.textColor =  UIColor(hexCode: "FFF9CA")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if goalTextFiled.text == "목표를 적어주세요!" {
            goalTextFiled.text = nil // 텍스트를 날려줌
            goalTextFiled.textColor =  UIColor(hexCode: "FFF9CA")
        }
    }
    //    let textViewPlaceHolder2 = "목표를 적어주세요!"
    @IBOutlet weak var goalTextFiled: UITextView!
    
    // 목표 전송
    @IBAction func sendGoal(_ sender: Any) {
        
        let mission = goalTextFiled.text
        let parameter: Parameters = [
            "mission": mission
        ]
        
        UserDefaults.standard.setValue(mission, forKey: "mission")
        
        let request = APIRequest(method: .post,
                                 path: "/goal",
                                 param: parameter,
                                 headers: APIConfig.authHeaders)
        
        APIService.shared.perform(memberId: UserInfo.memberId,
                                  request: request,
                                  completion: { (result) in
            switch result {
            case .success(let response):
                print("성공")
            case .failure:
                print(APIError.networkFailed)
            }
        })
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var goalView: UIView!{
        didSet{
            goalView.layer.cornerRadius = 15
            goalTextFiled.text = "목표를 적어주세요."
            if let mission = UserDefaults.standard.string(forKey: "mission"){
                if mission.count > 0{
                    goalTextFiled.text = UserDefaults.standard.string(forKey: "mission")
                }
            }
            goalTextFiled.tintColor = UIColor(hexCode: "FCFDFC")
        }
    }
    
    // 키보드 올라갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillShow(_ sender:Notification){
        self.view.frame.origin.y = 0
    }
    // 키보드 내려갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillHide(_ sender:Notification){
        self.view.frame.origin.y = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var imgList = [String]()
    
    func dataParsing() {
        // 이미지 list 가져오기
        let date = "/2023/12"
        let request = APIRequest(method: .get,
                                 path: "/image" + date,
                                 param: nil,
                                 headers: APIConfig.authHeaders)
        
        APIService.shared.perform(memberId: UserInfo.memberId,
                                  request: request,
                                  completion: { (result) in
            switch result {
            case .success:
                
                print(result)
            case .failure:
                print(APIError.networkFailed)
            }
        })
        
        if let imageDict = UserDefaults.standard.object([[Int: String]].self, with: "imgDict"){
            ImgdataCount = imageDict.count
            for i in imageDict{
                for j in i {
                    imgList.append(j.value)
                }
            }
        }
    }
    
    
}

// MARK: - CollectionView Handling
// Cell data 관련
extension HomeTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImgdataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
//        let fileName = imgList[ImgdataCount-indexPath.row-1]
//        
//        let fileURL = documentsUrl.appendingPathComponent(fileName)
//        do {
//            let imageData = try Data(contentsOf: fileURL)
//            cell.cellImage.image = UIImage(data: imageData)
//            cell.cellImage.contentMode = .scaleAspectFill
//        } catch {
//            print("Error loading image : \(error)")
//        }
        
        return cell
    }
}

// FlowLayout 관련
extension HomeTabViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let interval:CGFloat = 0
        let width: CGFloat = ( UIScreen.main.bounds.width - interval * 2 ) / 3
        return CGSize(width: width , height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
