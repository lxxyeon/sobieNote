//
//  RecordViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/7/23.
//

import UIKit
import Alamofire

// TAB2. 기록 게시물 업로드(추가) 화면
class BoardViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - parameter
    var boardData: BoardImage?
    
    //init data
    var categorie = ""
    var emotion = ""
    var factor = ""
    var satisfaction = ""
    var content = ""
    
    @IBOutlet weak var goalLabel: UILabel!{
        didSet{
            goalLabel.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet weak var objectImageView: UIImageView!{
        didSet{
            objectImageView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var tagListView1: UIView!
    @IBOutlet weak var tagListView2: UIView!
    @IBOutlet weak var tagListView3: UIView!
    @IBOutlet weak var tagListView4: UIView!
    
    @IBOutlet weak var tagListViewHeight1: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeight2: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeight3: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeight4: NSLayoutConstraint!
    
    @IBOutlet weak var saveBtn: UIButton!{
        didSet{
            saveBtn.layer.cornerRadius = 15
        }
    }
    
    // MARK: - text view
    let textViewPlaceHolder = "이 물건만의 매력 포인트나 구매 동기 등을 적어보세요!"
    @IBOutlet weak var recordTextView: UITextView!{
        didSet{
            recordTextView.delegate = self
            recordTextView.text = textViewPlaceHolder
            recordTextView.textColor = .lightGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if recordTextView.text.isEmpty {
            recordTextView.text = textViewPlaceHolder
            recordTextView.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if recordTextView.textColor == .lightGray {
            recordTextView.text = nil // 텍스트를 날려줌
            recordTextView.textColor = .black
        }
    }
    
    // MARK: - Keyboard Handeling
    // 키보드 올라갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillShow(_ sender:Notification){
        self.view.frame.origin.y = -280
    }
    // 키보드 내려갔다는 알림을 받으면 실행되는 메서드
    @objc func keyboardWillHide(_ sender:Notification){
        self.view.frame.origin.y = 0
    }
    // 키보드 내리기
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - 사진 선택
    var selectedImg = UIImage()
    var tagButtonArray = [UIButton]()
    var Picker = UIImagePickerController()
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        showActionSheet()
    }
    
    /// 이미지 변경 버튼 클릭시 생성되는 action sheet
    func showActionSheet() {
        
        // 액션 시트 초기화
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction 설정
        // handler : 액션 발생시 호출
        let actionAlbum = UIAlertAction(title: "앨범에서 선택할래요", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openGallery()
        })
        let actionCamera = UIAlertAction(title: "사진 찍을래요", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openCamera()
        })
        
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionAlbum)
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true)
    }
    /// actionsheet1. 카메라 촬영
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.Picker.sourceType = UIImagePickerController.SourceType.camera;
            self .present(self.Picker, animated: true, completion: nil)
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
        }
    }
    /// actionsheet2. 앨범에서 가져오기
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
            self.Picker.sourceType = UIImagePickerController.SourceType.photoLibrary;
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
            self.present(self.Picker, animated: true, completion: nil)
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // 갤러리 이미지 선택시 실행되는 메소드
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //선택한 이미지 처리
            //1. imageView로 보여주기
            let resizedImage = resizeImage(image: image, newWidth: 300)
            self.selectedImg = resizedImage
            
            DispatchQueue.main.async {
                self.objectImageView.image = self.selectedImg
                self.objectImageView.contentMode = .scaleAspectFill
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - tag view
    private lazy var tagCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        //tag 위아래
        layout.minimumLineSpacing = 5
        //tag 좌우
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var tagCollectionView2: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        //tag 위아래
        layout.minimumLineSpacing = 5
        //tag 좌우
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var tagCollectionView3: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        //tag 위아래
        layout.minimumLineSpacing = 5
        //tag 좌우
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var tagCollectionView4: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        //tag 위아래
        layout.minimumLineSpacing = 5
        //tag 좌우
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard 제어
        hideKeyboard()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        //collection view 1
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        tagListView1.addSubview(tagCollectionView)
        
        NSLayoutConstraint.activate([
            tagCollectionView.leadingAnchor.constraint(equalTo: tagListView1.leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: tagListView1.trailingAnchor),
            tagCollectionView.topAnchor.constraint(equalTo: tagListView1.safeAreaLayoutGuide.topAnchor),
            tagCollectionView.bottomAnchor.constraint(equalTo: tagListView1.safeAreaLayoutGuide.bottomAnchor)
        ])
        tagListViewHeight1.constant = tagListView1.frame.height
        
        //collection view 2
        tagCollectionView2.delegate = self
        tagCollectionView2.dataSource = self
        tagCollectionView2.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        tagListView2.addSubview(tagCollectionView2)
        
        NSLayoutConstraint.activate([
            tagCollectionView2.leadingAnchor.constraint(equalTo: tagListView2.leadingAnchor),
            tagCollectionView2.trailingAnchor.constraint(equalTo: tagListView2.trailingAnchor),
            tagCollectionView2.topAnchor.constraint(equalTo: tagListView2.safeAreaLayoutGuide.topAnchor),
            tagCollectionView2.bottomAnchor.constraint(equalTo: tagListView2.safeAreaLayoutGuide.bottomAnchor)
        ])
        tagListViewHeight2.constant = tagListView2.frame.height
        
        //collection view 3
        tagCollectionView3.delegate = self
        tagCollectionView3.dataSource = self
        tagCollectionView3.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        tagListView3.addSubview(tagCollectionView3)
        
        NSLayoutConstraint.activate([
            tagCollectionView3.leadingAnchor.constraint(equalTo: tagListView3.leadingAnchor),
            tagCollectionView3.trailingAnchor.constraint(equalTo: tagListView3.trailingAnchor),
            tagCollectionView3.topAnchor.constraint(equalTo: tagListView3.safeAreaLayoutGuide.topAnchor),
            tagCollectionView3.bottomAnchor.constraint(equalTo: tagListView3.safeAreaLayoutGuide.bottomAnchor)
        ])
        tagListViewHeight3.constant = tagListView3.frame.height
        
        //collection view 4
        tagCollectionView4.delegate = self
        tagCollectionView4.dataSource = self
        tagCollectionView4.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        tagListView4.addSubview(tagCollectionView4)
        
        NSLayoutConstraint.activate([
            tagCollectionView4.leadingAnchor.constraint(equalTo: tagListView4.leadingAnchor),
            tagCollectionView4.trailingAnchor.constraint(equalTo: tagListView4.trailingAnchor),
            tagCollectionView4.topAnchor.constraint(equalTo: tagListView4.safeAreaLayoutGuide.topAnchor),
            tagCollectionView4.bottomAnchor.constraint(equalTo: tagListView4.safeAreaLayoutGuide.bottomAnchor)
        ])
        tagListViewHeight4.constant = tagListView4.frame.height
        
        // image view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        objectImageView.isUserInteractionEnabled = true
        objectImageView.addGestureRecognizer(tapGestureRecognizer)
        
        //boardId 유무로 화면 데이터 변경
        if let receivedBoardImageData = self.boardData {
            // 1. image data mapping
            objectImageView.contentMode = .scaleAspectFill
            objectImageView.kf.setImage(with: URL(string:receivedBoardImageData.imagePath))
            
            // 2. tag data mapping
            let request = APIRequest(method: .get,
                                     path: "/board/posting" + "/\(receivedBoardImageData.boardId)",
                                     param: nil,
                                     headers: APIConfig.authHeaders)
            APIService.shared.perform(request: request,
                                      completion: { (result) in
                switch result {
                case .success(let data):
                    if let responseData = data.body["data"] as? [String:Any] {
                        self.categorie = responseData["categories"] as! String
                        self.emotion = responseData["emotions"] as! String
                        self.factor = responseData["factors"] as! String
                        self.satisfaction = "\(responseData["satisfactions"] as! Int)"
                        self.recordTextView.text = responseData["contents"] as? String
                        self.recordTextView.textColor = .black
                    }
                    DispatchQueue.main.async {
                        self.tagCollectionView.reloadData()
                        self.tagCollectionView2.reloadData()
                        self.tagCollectionView3.reloadData()
                        self.tagCollectionView4.reloadData()
                    }
                case .failure:
                    print(APIError.networkFailed)
                }
            })
            
            // 3. saveBtn title 변경
            saveBtn.setTitle("수정하기", for: .normal)
        }else{
            print("boardid nil")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let deleteButtonItem = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(boardDeleteAction(_:)))
        deleteButtonItem.tintColor = .red
        self.navigationItem.rightBarButtonItem = deleteButtonItem
    }
    
    // 게시물 삭제 API
    @objc private func boardDeleteAction(_ sender: Any) {

        if let boardId = self.boardData?.boardId {
            var alert = UIAlertController()
            alert = UIAlertController(title:"소비기록을 삭제하겠습니까?",
                                      message: "소비기록이 삭제됩니다.",
                                      preferredStyle: UIAlertController.Style.alert)
            self.present(alert,animated: true,completion: nil)
            let buttonLabel = UIAlertAction(title: "확인", style: .default, handler: {_ in
                let request = APIRequest(method: .delete,
                                         path: "/board/posting" + "/\(boardId)",
                                         param: nil,
                                         headers: APIConfig.authHeaders)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
                    switch result {
                    case .success:
                        AlertView.showAlert(title: Global.boardDeleteSuccessTitle,
                                            message: nil,
                                            viewController: self,
                                            dismissAction: UIViewController.changeRootVCToHomeTab)
                    case .failure:
                        print(APIError.networkFailed)
                    }}
                )
            })
            alert.addAction(buttonLabel)
        }
    }
    
    // 작성한 기록 서버 전송 API
    @IBAction func sendRecordToServer(_ sender: Any) {
        var alert = UIAlertController()
        content = recordTextView.text
        let recordParam: Parameters = ["contents": content,
                                       "emotions": emotion,
                                       "satisfactions": satisfaction,
                                       "factors": factor,
                                       "categories": categorie]
        if let imgData = self.objectImageView.image {

            if let boardId = self.boardData?.boardId {
                // 게시물 수정하기 api
                APIService.shared.fileUpload(imageData: imgData,
                                             method: .patch,
                                             path: "\(boardId)",
                                             parameters: recordParam,completion: { postNumber in
                    AlertView.showAlert(title: Global.boardModifySuccessTitle,
                                        message: nil,
                                        viewController: self,
                                        dismissAction: UIViewController.changeRootVCToHomeTab)
                })
            }else{
                // 게시물 저장하기 api
                APIService.shared.fileUpload(imageData: imgData,
                                             method: .post,
                                             path: UserInfo.memberId,
                                             parameters: recordParam,completion: { postNumber in
                    AlertView.showAlert(title: Global.boardRecordSuccessTitle,
                                        message: nil,
                                        viewController: self,
                                        dismissAction: UIViewController.changeRootVCToHomeTab)
                })
            }
        }
    }
}

extension BoardViewController: UICollectionViewDelegate , UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagCollectionView {
            return Tags.TagList1.count
        }else if collectionView == tagCollectionView2{
            return Tags.TagList2.count
        }else if collectionView == tagCollectionView3{
            return Tags.TagList3.count
        }else if collectionView == tagCollectionView4{
            return Tags.TagList4.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell else {
            return UICollectionViewCell()
        }
        
        cell.backgroundColor = .white
        if collectionView == tagCollectionView {
            cell.tagLabel.text = Tags.TagList1[indexPath.row]
            if cell.tagLabel.text == self.categorie {
                collectionView.selectItem(at: indexPath, animated: false , scrollPosition: .init())
                cell.isSelected = true
            }
        }else if collectionView == tagCollectionView2{
            cell.tagLabel.text = Tags.TagList2[indexPath.row]
            if cell.tagLabel.text == self.emotion {
                collectionView.selectItem(at: indexPath, animated: false , scrollPosition: .init())
                cell.isSelected = true
            }
        }else if collectionView == tagCollectionView3{
            cell.tagLabel.text = Tags.TagList3[indexPath.row]
            if cell.tagLabel.text == self.factor {
                collectionView.selectItem(at: indexPath, animated: false , scrollPosition: .init())
                cell.isSelected = true
            }
        }else if collectionView == tagCollectionView4{
            cell.tagLabel.text = Tags.TagList4[indexPath.row]
            if cell.tagLabel.text == self.satisfaction {
                collectionView.selectItem(at: indexPath, animated: false , scrollPosition: .init())
                cell.isSelected = true
            }
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tagCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
                categorie = cell.tagLabel.text!
            }
        }else if collectionView == tagCollectionView2{
            if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
                emotion = cell.tagLabel.text!
            }
        }else if collectionView == tagCollectionView3{
            if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
                factor = cell.tagLabel.text!
            }
        }else if collectionView == tagCollectionView4{
            if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
                satisfaction = cell.tagLabel.text!
            }
        }
    }
}
extension BoardViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    //화면 클릭
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}

extension BoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label: UILabel = {
            let customLabel = UILabel()
            customLabel.font = .systemFont(ofSize: 16)
            if collectionView == tagCollectionView {
                customLabel.text = Tags.TagList1[indexPath.row]
            }else if collectionView == tagCollectionView2{
                customLabel.text = Tags.TagList2[indexPath.item]
            }else if collectionView == tagCollectionView3{
                customLabel.text = Tags.TagList3[indexPath.item]
            }else if collectionView == tagCollectionView4{
                customLabel.text = Tags.TagList4[indexPath.item]
            }
            customLabel.sizeToFit()
            return customLabel
        }()
        let size = label.frame.size
        return CGSize(width: size.width + 24, height: 40)
    }
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
    }
}
