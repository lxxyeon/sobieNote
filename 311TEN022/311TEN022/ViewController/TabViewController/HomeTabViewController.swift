//
//  HomeTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import Alamofire

class HomeTabViewController: UIViewController, UITextViewDelegate {
    let margin: CGFloat = 1
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
    @IBAction func sendGoal(_ sender: Any) {
        print("목표 전송")
        let mission = goalTextFiled.text
        let parameter: Parameters = [
            "mission": mission
        ]
        
        UserDefaults.standard.setValue(mission, forKey: "mission")
        
        APIService.shared.goalSave(param: parameter, completion: {_ in
            var alert = UIAlertController()
            alert = UIAlertController(title:"목표가 저장됐어요!",
                                      message: "",
                                      preferredStyle: UIAlertController.Style.alert)
            self.present(alert,animated: true,completion: nil)
            let buttonLabel = UIAlertAction(title: "확인", style: .default, handler: {_ in
                self.dismiss(animated:true, completion: nil)
            })
            alert.addAction(buttonLabel)
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
        if let imageDict = UserDefaults.standard.object([[Int: String]].self, with: "imgDict"){
            ImgdataCount = imageDict.count
            for i in imageDict{
                for j in i {
                    imgList.append(j.value)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataParsing()
        self.goalTextFiled.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
    }
    
    
}

extension HomeTabViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 3  //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImgdataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }

        let fileName = imgList[ImgdataCount-indexPath.row-1]
        
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            cell.cellImage.image = UIImage(data: imageData)
            cell.cellImage.contentMode = .scaleAspectFill
        } catch {
            print("Error loading image : \(error)")
        }
        

        return cell
    }
}
