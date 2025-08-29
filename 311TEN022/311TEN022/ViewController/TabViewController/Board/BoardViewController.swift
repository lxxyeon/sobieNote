//
//  RecordViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/7/23.
//

import UIKit
import Alamofire
import AVFoundation
import Photos
import Lottie

// MARK: - TAB2. 기록 게시물 업로드(추가) 화면
class BoardViewController: UIViewController, UINavigationControllerDelegate {
    let animationView: LottieAnimationView = .init(name: "DotsAnimation")
    // MARK: - Properties
    var selectedImg = UIImage()
    var tagButtonArray = [UIButton]()
    var Picker = UIImagePickerController()
    var boardData: BoardImage?
    var categorie = ""
    var emotion = ""
    var factor = ""
    var satisfaction = ""
    var content = ""
    var imgSelectFlag = false
    // textView max count
    let maxCount = 100
    
    // MARK: - 동적 높이 조정을 위한 속성
    private let minTextViewHeight: CGFloat = 100
    private let maxTextViewHeight: CGFloat = 200
    
    // TextView와 관련된 컸테이너 높이 제약조건들
    var textViewContainerHeightConstraint: NSLayoutConstraint?
    var strokeViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Segment Control 관련 속성
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    @IBOutlet weak var segmentContainerView: UIView?
    
    // 각 세그먼트에 해당하는 뷰들
    @IBOutlet weak var firstSegmentView: UIView?
    @IBOutlet weak var secondSegmentView: UIView?
    @IBOutlet weak var thirdSegmentView: UIView?
    
    // 뷰 배열로 관리
    private var segmentViews: [UIView] = []

    // MARK: - UI Component
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var boardScrollView: UIScrollView!{
        didSet{
            boardScrollView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Segment Control Setup
    private func setupSegmentControl() {
        guard let segmentControl = segmentedControl else { return }
        
        // 세그먼트 컴트롤 초기 설정
        segmentControl.selectedSegmentIndex = 0
        
        // 스타일 커스터마이징
        segmentControl.backgroundColor = UIColor.systemGray6
        segmentControl.selectedSegmentTintColor = UIColor.Point() // 기존 Point 색상 사용
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        // 세그먼트 뷰 배열 초기화
        setupSegmentViews()
        
        // 초기 뷰 표시
        showSegmentView(at: 0)
    }
    
    private func setupSegmentViews() {
        // nil이 아닌 뷰들만 배열에 추가
        segmentViews = [firstSegmentView, secondSegmentView, thirdSegmentView].compactMap { $0 }
        
        // 모든 뷰 숨기기
        segmentViews.forEach { view in
            view.isHidden = true
            setupIndividualSegmentView(view)
        }
    }
    
    private func setupIndividualSegmentView(_ view: UIView) {
        // 각 세그먼트 뷰의 기본 스타일 설정
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = UIColor.systemBackground
        
        // 경계선 추가 (선택사항)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        showSegmentView(at: sender.selectedSegmentIndex)
    }
    
    private func showSegmentView(at index: Int) {
        // 모든 뷰 숨기기
        segmentViews.forEach { $0.isHidden = true }
        
        // 선택된 인덱스의 뷰만 보이기
        if index < segmentViews.count {
            let selectedView = segmentViews[index]
            selectedView.isHidden = false
            
            // 애니메이션 효과 추가
            animateSegmentViewTransition(view: selectedView)
        }
    }
    
    private func animateSegmentViewTransition(view: UIView) {
        // 페이드 인 애니메이션
        view.alpha = 0
        view.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 1
        })
    }
    
    // MARK: - Segment View Content Setup (예시)
    private func setupSegmentViewContents() {
        // 첫 번째 세그먼트 뷰 설정
        if let firstView = firstSegmentView {
            let label = UILabel()
            label.text = "첫 번째 세그먼트"
            label.textAlignment = .center
            label.font = UIFont.kimR18()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            firstView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: firstView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: firstView.centerYAnchor)
            ])
        }
        
        // 두 번째, 세 번째 세그먼트도 비슷하게 설정...
    }
    
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
    
    @IBOutlet weak var strokeView: UIView!{
        didSet{
            strokeView.backgroundColor = UIColor(hexCode: "#8D8E8A")
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
            typealias SFConfig = UIImage.SymbolConfiguration
            saveBtn.layer.cornerRadius = 15
            saveBtn.tintColor = .white
            saveBtn.titleLabel?.font = UIFont.kimB18()
            saveBtn.titleLabel?.textColor = .white
            saveBtn.layer.borderWidth = 2
            saveBtn.backgroundColor = UIColor.Point()
            saveBtn.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet weak var recordTextView: UITextView!{
        didSet{
            recordTextView.delegate = self
            recordTextView.text = Global.recordTextViewPlaceHolder
            recordTextView.font = UIFont.kimR18()
            recordTextView.textColor = .lightGray
            recordTextView.isScrollEnabled = false // 스크롤 비활성화로 높이 자동 조정
        }
    }
    
    var recordTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textCountLabel: UILabel!{
        didSet{
            textCountLabel.font = UIFont.kimR14()
            textCountLabel.textColor = .darkGray
        }
    }
    
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
    
    // MARK: - Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        // Segment Control 초기화
        self.setupSegmentControl()
        
        // 스크롤뷰 드래그 시 키패드 내려감
        self.boardScrollView.keyboardDismissMode = .onDrag
        
        // 키패드 감지 observer 등록
        // 키패드 내려감 감지
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        // 키패드 올라감 감지
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        // 화면 터치 인식 - 키패드 내려감
        let keypadGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.view.addGestureRecognizer(keypadGesture)
        keypadGesture.delegate = self
        
        // image view 터치 인식
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        objectImageView.isUserInteractionEnabled = true
        objectImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // boardId 유무로 화면 데이터 변경, boardId 있으면 수정하기 화면
        if let receivedBoardImageData = self.boardData {
            // 수정화면인 경우
            // 1. 네비게이션바 활성화
            navigationController?.setNavigationBarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = true
            // 2. 기록 데이터 매핑
            // 2-1) image data mapping
            imgSelectFlag = true
            objectImageView.contentMode = .scaleAspectFill
            objectImageView.kf.setImage(with: URL(string:receivedBoardImageData.imagePath))
            
            // 2-2) tag data mapping
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
                        self.recordTextView.text = (responseData["contents"] as! String)
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
            //            print("boardid nil")
        }
    }
    
    func setupUI() {
        // collection view 1
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
        print(tagCollectionView.frame.height)
        tagListViewHeight1.constant = tagListView1.frame.height
        
        // TextView Height Constraint 생성 및 설정
        createTextViewHeightConstraint()
        
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
    }
    
    // MARK: - TextView Height Constraint 생성
    private func createTextViewHeightConstraint() {
        // 기존 height constraint가 있다면 제거
        recordTextView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
                recordTextView.removeConstraint(constraint)
            }
        }
        
        // TextView 새로운 height constraint 생성
        recordTextViewHeightConstraint = recordTextView.heightAnchor.constraint(equalToConstant: minTextViewHeight)
        recordTextViewHeightConstraint.isActive = true
        
        // StrokeView와 TextView를 감싸는 컸테이너의 높이 제약조건 설정
        setupRelatedViewConstraints()
        
        // 초기 높이 설정
        recordTextViewHeightConstraint.constant = minTextViewHeight
    }
    
    // MARK: - 관련 뷰들의 제약조건 설정
    private func setupRelatedViewConstraints() {
        // 1. IBOutlet으로 연결된 제약조건들 우선 사용
//        if let strokeConstraint = strokeViewHeightConstraintOutlet {
//            strokeViewHeightConstraint = strokeConstraint
//        } else {
//            // 2. strokeView의 높이 제약조건 직접 찾기
//            strokeView.constraints.forEach { constraint in
//                if constraint.firstAttribute == .height {
//                    strokeViewHeightConstraint = constraint
//                }
//            }
//        }
//        
//        // 3. 스택뷰 제약조건 설정
//        if let stackViewConstraint = textViewStackViewHeightConstraint {
//            textViewContainerHeightConstraint = stackViewConstraint
//        } else {
//            // 4. TextView를 감싸는 컸테이너 또는 스택뷰의 높이 제약조건 찾기
//            findContainerHeightConstraint()
//        }
    }
    
    // MARK: - 컸테이너 높이 제약조건 찾기
    private func findContainerHeightConstraint() {
        // recordTextView의 직접 부모부터 시작
        var currentView: UIView? = recordTextView.superview
        
        while let view = currentView {
            // 현재 뷰의 제약조건들 검사
            for constraint in view.constraints {
                if constraint.firstAttribute == .height {
                    // 자기 자신의 높이 제약조건인지 확인
                    if constraint.firstItem as? UIView == view ||
                       constraint.secondItem as? UIView == view {
                        textViewContainerHeightConstraint = constraint
                        print("찾은 컸테이너: \(view), 제약조건: \(constraint.constant)")
                        return
                    }
                }
            }
            
            // 부모 뷰의 제약조건들도 검사 (상위 뷰에서 설정된 경우)
            if let parentView = view.superview {
                for constraint in parentView.constraints {
                    if constraint.firstAttribute == .height &&
                       (constraint.firstItem as? UIView == view || constraint.secondItem as? UIView == view) {
                        textViewContainerHeightConstraint = constraint
                        print("찾은 컸테이너(부모에서): \(view), 제약조건: \(constraint.constant)")
                        return
                    }
                }
            }
            
            currentView = view.superview
            // contentView에 도달하면 중단
            if view == contentView {
                break
            }
        }
    }
    
    // MARK: - Methods
    // textview focus 감지
    func textViewDidBeginEditing(_ textView: UITextView) {
        if recordTextView.textColor == .lightGray {
            recordTextView.text = nil // 텍스트를 날려줌
            recordTextView.textColor = .black
            
            // 플레이스홀더 제거 후 높이 재조정
            adjustTextViewHeight()
        }
    }
    
    // textview 관련 메소드
    // 키보드 올라갔다는 알림을 받으면 실행되는 메서드
    @objc private func keyboardWillShow(_ sender:Notification){
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
//        if self.view.frame.origin.y == 0 {
            //높이 조정 커스텀 가능
            self.view.frame.origin.y -= 240
//        }
//        self.view.frame.origin.y = -240
    }
    
    // 키보드 내려갔다는 알림을 받으면 실행되는 메서드
    @objc private func keyboardWillHide(_ sender:Notification){
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = -(self.tabBarController?.tabBar.frame.height ?? 0)/2 + 20
        }
    }
    
    // 키보드 내리기
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // 사진 추가 이미지 터치시 호출
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        showActionSheet()
    }
    
    /// 이미지 변경 버튼 클릭시 생성되는 action sheet
    private func showActionSheet() {
        
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
    private func openCamera()
    {
        //1. permission check
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                //2. 카메라 실행
                if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
                {
                    //UIImagePickerController must be used from main thread only
                    DispatchQueue.main.async {
                        self.Picker.sourceType = UIImagePickerController.SourceType.camera;
                        self.Picker.allowsEditing = true
                        self.Picker.delegate = self
                        self.present(self.Picker, animated: true, completion: nil)
                    }
                }
            } else {
                self.showAlertGoToSetting(type: "카메라")
            }
        }
    }
    
    /// actionsheet2. 앨범에서 가져오기
    private func openGallery()
    {
        PHPhotoLibrary.requestAuthorization({ granted in
            switch granted{
            case .authorized:
                DispatchQueue.main.async {
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
                        self.Picker.sourceType = UIImagePickerController.SourceType.photoLibrary;
                        self.Picker.allowsEditing = true
                        self.Picker.delegate = self
                        self.present(self.Picker, animated: true, completion: nil)
                    }
                }
            case .denied:
                // 앱 권한 설정으로 이동
                self.showAlertGoToSetting(type: "앨범")
            default:
                break
            }
        })
    }
    
    // 카메라 권한 없는 경우 설정으로 이동
    func showAlertGoToSetting(type: String) {
        let alertController = UIAlertController(
            title: "현재 \(type) 사용에 대한 접근 권한이 없습니다.",
            message: "설정 > [소비기록] 탭에서 접근을 활성화 할 수 있습니다.",
            preferredStyle: .alert
        )
        let cancelAlert = UIAlertAction(
            title: "취소",
            style: .cancel
        ) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        let goToSettingAlert = UIAlertAction(
            title: "설정으로 이동하기",
            style: .default) { _ in
                guard
                    let settingURL = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingURL)
                else { return }
                UIApplication.shared.open(settingURL, options: [:])
            }
        [cancelAlert, goToSettingAlert]
            .forEach(alertController.addAction(_:))
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    /// 기록 이미지 resize
    /// - Parameters:
    ///   - image: 기록 이미지
    ///   - newWidth: resize할 가로 길이
    /// - Returns: resize 이미지(
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // 화면 터치 인식 메소드
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true) // todo...
        }
        sender.cancelsTouchesInView = false
    }

    // 탭바 높이 조정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBarController?.tabBar.frame.size.height = 90
    }
    
    //화면 터치 감지
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.kimR18()]
        let deleteButtonItem = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(boardDeleteAction(_:)))
        deleteButtonItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = deleteButtonItem
      
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.backgroundColor = UIColor(hexCode: "#E6F4F1")
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.standardAppearance = appearance
    
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
                let animationView: LottieAnimationView = .init(name: "DotsAnimation")
                self.view.addSubview(animationView)
                animationView.frame = self.view.bounds
                animationView.center = self.view.center
                animationView.contentMode = .scaleAspectFit
                animationView.play()
                animationView.loopMode = .loop
                
                let request = APIRequest(method: .delete,
                                         path: "/board/posting" + "/\(boardId)",
                                         param: nil,
                                         headers: APIConfig.authHeaders)
                APIService.shared.perform(request: request,
                                          completion: { [self] (result) in
//                    animationView.stop()
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
            
            let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: { _ in
                // 취소 시 아무것도 하지 않음 (Alert만 닫힘)
                print("삭제 취소됨")
            })
            
            // 버튼들을 Alert에 추가
            alert.addAction(buttonLabel)
            alert.addAction(cancelButton)
        }
    }
    
    func paramValidate() -> Parameters? {
        var param = ""
        if !imgSelectFlag{
            animationView.stop()
            animationView.removeFromSuperview()
            AlertView.showAlert(title: "사진을 추가해주세요. ",
                                message: nil,
                                viewController: self,
                                dismissAction: nil)
            return nil
        }
        content = recordTextView.text
        // parameter validate
        if emotion.isEmpty {
            param = "감정을"
        }
        
        if satisfaction.isEmpty{
            param = "만족도를"
        }
        
        if factor.isEmpty{
            param = "요소를"
        }
        
        if categorie.isEmpty{
            param = "카테고리를"
        }
        
        if recordTextView.text == Global.recordTextViewPlaceHolder || recordTextView.text.count < 1 {
            param = "상세 기록 내용을"
        }
        
        if !param.isEmpty {
            animationView.stop()
            animationView.removeFromSuperview()
            AlertView.showAlert(title: "\(param) 기록해주세요.",
                                message: nil,
                                viewController: self,
                                dismissAction: nil)
            return nil
        }

        let recordParam: Parameters = ["contents": content,
                                       "emotions": emotion,
                                       "satisfactions": satisfaction,
                                       "factors": factor,
                                       "categories": categorie]
        
        return recordParam
    }
    
    func enc(_ inputStr:String) -> String{
        let data = inputStr.data(using: .nonLossyASCII, allowLossyConversion: true)!
        
        if let outputStr = String(data: data, encoding: .utf8){
            return outputStr
        } else{
            print("Encoding Failed")
            return ""
        }
    }
    
    func dec(_ inputStr:String) -> String{
        let data = inputStr.data(using: .utf8)!
        
        if let outputStr = String(data: data, encoding: .nonLossyASCII){
            return outputStr
        } else {
            print("Decoding Failed")
            return ""
        }
    }
    
    // 기록하기 버튼 - 작성한 기록 서버 전송 API 수행
    @IBAction func sendRecordToServer(_ sender: Any) {
       
        self.view.addSubview(animationView)
        self.animationView.frame = self.view.bounds
        self.animationView.center = self.view.center
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.play()
        self.animationView.loopMode = .loop
        
        if let recordParam = self.paramValidate() {
            if let imgData = self.objectImageView.image {
                if let boardId = self.boardData?.boardId {
                    // 게시물 수정하기 api
                    APIService.shared.fileUpload(imageData: imgData,
                                                 method: .patch,
                                                 path: "\(boardId)",
                                                 parameters: recordParam,
                                                 completion: { [self] postNumber in
//                        animationView.stop()
                        self.saveBtn.isEnabled = true
                        self.animationView.stop()
                        self.animationView.removeFromSuperview()
                        AlertView.showAlert(title: Global.boardModifySuccessTitle,
                                            message: nil,
                                            viewController: self,
                                            dismissAction: UIViewController.changeRootVCToHomeTab)
                    })
                }else{
                    // 게시물 저장하기 api
                    // 파일 업로드 api
                    APIService.shared.fileUpload(imageData: imgData,
                                                 method: .post,
                                                 path: UserInfo.memberId,
                                                 parameters: recordParam,
                                                 completion: { postNumber in
                        if let postNumber = postNumber{
                            self.animationView.stop()
                            self.animationView.removeFromSuperview()
                            AlertView.showAlert(title: Global.boardRecordSuccessTitle,
                                                message: nil,
                                                viewController: self,
                                                dismissAction: UIViewController.changeRootVCToHomeTab)
                        }else {
                            self.animationView.stop()
                            self.animationView.removeFromSuperview()
                            AlertView.showAlert(title: Global.boardRecordFailTitle,
                                                message: nil,
                                                viewController: self,
                                                dismissAction: nil)
                        }
                        self.saveBtn.isEnabled = true
                    })
                }
            }else{
                self.saveBtn.isEnabled = true
                AlertView.showAlert(title: Global.boardModifySuccessTitle,
                                    message: nil,
                                    viewController: self,
                                    dismissAction: nil)
            }
        }
    }
    
    private func startLoading() {
        saveBtn.isEnabled = false
        
        let animationView: LottieAnimationView = .init(name: "DotsAnimation")
        animationView.tag = 999 // 나중에 찾기 위한 태그
        self.view.addSubview(animationView)
        animationView.frame = self.view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.loopMode = .loop
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

extension BoardViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = String(recordTextView.text.count) + "/100"
        // 글자수가 초과 된 경우
        if textView.text.count >= maxCount {
            textCountLabel.font = UIFont.kimR14()
            textCountLabel.textColor = #colorLiteral(red: 0.8470588235, green: 0.1176470588, blue: 0, alpha: 1)
        }else{
            textCountLabel.font = UIFont.kimR14()
            textCountLabel.textColor = .darkGray
        }
        
        // 동적 높이 조정
        adjustTextViewHeight()
    }
    
    // MARK: - TextView 높이 동적 조정
    private func adjustTextViewHeight() {
        guard recordTextViewHeightConstraint != nil else { return }
        
        let fixedWidth = recordTextView.frame.size.width
        let newSize = recordTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        // 최소/최대 높이 제한
        var newHeight = max(newSize.height, minTextViewHeight)
        newHeight = min(newHeight, maxTextViewHeight)
        
        // 높이가 변경된 경우에만 애니메이션 적용
        if recordTextViewHeightConstraint.constant != newHeight {
            let heightDifference = newHeight - recordTextViewHeightConstraint.constant
            
            // TextView 높이 업데이트
            recordTextViewHeightConstraint.constant = newHeight
            
            // 관련 뷰들의 높이도 함께 조정
            updateRelatedViewHeights(heightDifference: heightDifference)
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                // 스크롤뷰의 컨텐츠 사이즈도 업데이트
                self.updateScrollViewContentSize()
            }
        }
        
        // 최대 높이에 도달하면 스크롤 활성화
        recordTextView.isScrollEnabled = newHeight >= maxTextViewHeight
    }
    
    // MARK: - 관련 뷰들의 높이 업데이트
    private func updateRelatedViewHeights(heightDifference: CGFloat) {
        // StrokeView의 높이 조정 (선택사항)
        if let strokeConstraint = strokeViewHeightConstraint {
            strokeConstraint.constant += heightDifference
        }
        
        // TextView를 감싸는 컸테이너의 높이 조정
        if let containerConstraint = textViewContainerHeightConstraint {
            containerConstraint.constant += heightDifference
        }
        
        // 추가적으로 스택뷰나 다른 컸테이너가 있다면 여기서 조정
        adjustParentStackViewIfNeeded(heightDifference: heightDifference)
    }
    
    // MARK: - 부모 스택뷰 높이 조정
    private func adjustParentStackViewIfNeeded(heightDifference: CGFloat) {
        // recordTextView의 부모 뷰들을 순회하며 스택뷰 찾기
        var currentView: UIView? = recordTextView.superview
        
        while let view = currentView {
            if let stackView = view as? UIStackView {
                // 스택뷰의 높이 제약조건 찾기
                for constraint in view.constraints {
                    if constraint.firstAttribute == .height && constraint.firstItem as? UIView == stackView {
                        constraint.constant += heightDifference
                        break
                    }
                }
                break // 첫 번째 스택뷰만 조정
            }
            currentView = view.superview
            // contentView에 도달하면 중단
            if view == contentView {
                break
            }
        }
    }
    
    // MARK: - 스크롤뷰 컨텐츠 사이즈 업데이트
    private func updateScrollViewContentSize() {
        DispatchQueue.main.async {
            self.boardScrollView.layoutIfNeeded()
            // 필요시 컨텐츠 사이즈 수동 업데이트
            if let contentView = self.contentView {
                let contentHeight = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                self.boardScrollView.contentSize = CGSize(width: self.boardScrollView.frame.width, height: contentHeight)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let newLength = textView.text.count - range.length + text.count
        let koreanMaxCount = maxCount
        // 글자수가 초과 된 경우
        if newLength > koreanMaxCount {

            let overflow = newLength - koreanMaxCount //초과된 글자수
            if text.count < overflow {
                return true
            }
            let index = text.index(text.endIndex, offsetBy: -overflow)
            let newText = text[..<index]
            guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location) else { return false }
            guard let endPosition = textView.position(from: textView.beginningOfDocument, offset: NSMaxRange(range)) else { return false }
            guard let textRange = textView.textRange(from: startPosition, to: endPosition) else { return false }
                
            textView.replace(textRange, withText: String(newText))
            
            // 텍스트 변경 후 높이 조정
            DispatchQueue.main.async {
                self.adjustTextViewHeight()
            }
            
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
}

// MARK: - extension
extension BoardViewController: UIImagePickerControllerDelegate  {
    // 갤러리 이미지 선택시 실행되는 메소드
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // editedImage : crop 된 이미지 저장
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // 선택한 이미지 처리 - 이미지 선택했음을 알려주는 Flag 추가
            self.imgSelectFlag = true
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
}

extension BoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label: UILabel = {
            let customLabel = UILabel()
            customLabel.font = UIFont.kimR16()
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

extension BoardViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: saveBtn) == true {
            return false
        }
        return true
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
