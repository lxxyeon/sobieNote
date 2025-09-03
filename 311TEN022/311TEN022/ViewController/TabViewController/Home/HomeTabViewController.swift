//
//  HomeTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import Alamofire
import Kingfisher
import RxSwift
import RxAlamofire
import Lottie

// MARK: - TAB1. 홈 화면
class HomeTabViewController: UIViewController {
    
    // MARK: - UI Components
    let calendarView = CalendarView()
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var emptyImgView: UIImageView!
    @IBOutlet weak var TitleStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = "\u{1F5D3} \(Global.shared.selectedMonth!)월 소비기록"
            titleLabel.font = UIFont.kimR17()
        }
    }
    
    @IBOutlet weak var subTitle: UILabel!{
        didSet{
            subTitle.font = UIFont.kimR16()
        }
    }
    
    
    // MARK: - Rx Properties
    private let disposeBag = DisposeBag()
    private lazy var viewModel = HomeViewModel()
    var calendarIsHidden: Bool = true
    
    // 타이틀스택 클릭시 calendar 보여주는 action
    @objc func didTapStackView (sender: UITapGestureRecognizer) {
        if calendarIsHidden {
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(calendarView)
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: TitleStackView.bottomAnchor),
                calendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                calendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                calendarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            calendarIsHidden = false
        }else{
            calendarView.removeFromSuperview()
            calendarIsHidden = true
        }
    }
    
    func createPath() -> CGPath {
        let path = UIBezierPath(roundedRect: self.tabBarController?.tabBar.bounds ?? CGRect(),
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 20, height: 20))
        return path.cgPath
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 탭바 높이 조정
        self.tabBarController?.tabBar.frame.size.height = 90
        ////        self.tabBarController?.tabBar.frame.origin.y = view.frame.height - 95
    }
    
    // MARK: - CONFIGURATION
    private func bindUI() {
        //        imgCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        //        /// CollectionView layout
        //        let layout = UICollectionViewFlowLayout()
        //        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //        layout.minimumLineSpacing = 0
        //        layout.minimumInteritemSpacing = 0
        //
        //        imgCollectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        //        imgCollectionView.collectionViewLayout = layout
    }
    
    private func setProperties() {
        imgCollectionView.keyboardDismissMode = .onDrag
    }
    
    private func bindViewModel() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 조회 후 없는 경우 init 이미지 로드
        self.emptyImgView.isHidden = true
        //        bindUI()
        //        setProperties()
        //        bindViewModel()
        
        // 설정 메뉴
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.kimB19()]
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.kimR14()]
        //        appearance.backgroundColor = UIColor(hexCode: "FCFDFC")
        self.tabBarController?.tabBar.standardAppearance = appearance
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = createPath()
        self.tabBarController?.tabBar.layer.mask = maskLayer
        
        // 최초 1 회 호출
        calendarView.calendarSetup(type: 1)
        calendarView.changeCalenderBool = true
        calendarView.delegate = self
        self.dataParsing(year: Global.shared.selectedYear,
                         month: Global.shared.selectedMonth)
        
        
        // keyboard 제어
        hideKeyboard()
        
        TitleStackView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapStackView(sender:)))
        TitleStackView.addGestureRecognizer(tap)
        imgCollectionView.keyboardDismissMode = .onDrag
    }
    
    // 설정메뉴에서 돌아옴
    override func viewWillAppear(_ animated: Bool) {
        //        self.titleLabel.text = "\(Global.shared.currentMonth!)월 소비기록"
        // 날짜가 현재 날짜가 아닌 경우 재호출
        //        if Global.shared.selectedMonth != Global.shared.currentMonth || Global.shared.selectedYear != Global.shared.currentYear {
        //            dataParsing(year: Global.shared.currentYear,
        //                        month: Global.shared.currentMonth)
        //        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        viewDidLayoutSubviews()
    }
    
    // 설정메뉴로 가기 직전
    override func viewWillDisappear(_ animated: Bool) {
        //이거 들어가면 탭바 높이 원복된다?
        //        let backBarButtonItem = UIBarButtonItem(title: "뒤로가기", style: .plain, target: self, action: nil)
        //        backBarButtonItem.tintColor = .black  // 색상 변경
        //        self.navigationItem.backBarButtonItem = backBarButtonItem
        //        navigationController?.setNavigationBarHidden(false, animated: true)
        //        viewDidLayoutSubviews()
    }
    
    // MARK: - Goal TextView
    @IBOutlet weak var goalView: UIView!{
        didSet{
            goalView.layer.cornerRadius = 30
        }
    }
    
    let textViewPlaceHolder = "목표를 적어주세요."
    
    @IBOutlet weak var goalTextFiled: UITextView!{
        didSet{
            goalTextFiled.delegate = self
            goalTextFiled.font = UIFont.kimB20()
            goalTextFiled.text = textViewPlaceHolder
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if goalTextFiled.text.isEmpty {
            goalTextFiled.text = textViewPlaceHolder
            goalTextFiled.textColor = .black
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if goalTextFiled.text == textViewPlaceHolder || goalTextFiled.text == " " {
            goalTextFiled.text = nil // 텍스트를 날려줌
            goalTextFiled.textColor = .black
        }
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
    
    // utf8 > nonLossyASCII
    func dec(_ inputStr:String) -> String{
        let data = inputStr.data(using: .utf8)!
        
        if let outputStr = String(data: data, encoding: .nonLossyASCII){
            return outputStr
        } else {
            print("Decoding Failed")
            return ""
        }
    }
    
    /// 목표 전송 API
    @IBAction func sendGoal(_ sender: Any) {
        let newGoal = goalTextFiled.text
        
        let parameter: Parameters = [
            "mission": newGoal ?? " "
        ]
        
        var setGoalPath = "/goal" + "/\(UserInfo.memberId)"
        
        if let currentYear = Global.shared.selectedYear {
            setGoalPath.append("?year=\(currentYear)")
        }
        
        if let currentMonth = Global.shared.selectedMonth {
            setGoalPath.append("&month=\(currentMonth)")
        }
        
        let request = APIRequest(method: .post,
                                 path: setGoalPath,
                                 param: parameter,
                                 headers: APIConfig.authHeaders)
        
        APIService.shared.perform(request: request,
                                  completion: { [self] (result) in
            switch result {
            case .success:
                UserDefaults.standard.setValue(newGoal, forKey: "mission")
                if let currentMonth = Global.shared.selectedMonth {
                    AlertView.showAlert(title: "\(currentMonth)월 목표가 저장됐어요!",
                                        message: nil,
                                        viewController: self,
                                        dismissAction: self.dismissKeyboard)
                }
            case .failure:
                print("🚩 목표 POST API Response Error : \(APIError.networkFailed)")
                
            }
        })
    }
    
    // MARK: - Keyboard Handeling
    // 키보드 내리기
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    // 보고서 이미지
    var reportImgList = [BoardImage]()
    
    // 데이터 변경 감지
    func dataParsing(year: String, month: String) {
        // animation
        let animationView: LottieAnimationView = .init(name: "DotsAnimation")
        self.view.addSubview(animationView)
        animationView.frame = self.view.bounds
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.loopMode = .loop
        
        // 1. 이미지 list GET API
        let selectedData = "/" + year + "/" + month
        let request = APIRequest(method: .get,
                                 path: "/image" + selectedData + "/\(UserInfo.memberId)",
                                 param: nil,
                                 headers: APIConfig.authHeaders)
        APIService.shared.perform(request: request,
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
                    animationView.stop()
                    animationView.removeFromSuperview()
                }
            case .failure:
                print("🚩 이미지 리스트 GET API Response Error :\(APIError.networkFailed)")
                
                // 멤버 조회 후 없는 경우 로그아웃, 있으면 재시도
                let getUserInfourl =  "/member/" + "\(UserInfo.memberId)"
                let request = APIRequest(method: .get,
                                         path: getUserInfourl,
                                         param: nil,
                                         headers: APIConfig.authHeaders)
                APIService.shared.perform(request: request) { [weak self] result in
                    switch result {
                    case .success(let response):
                        AlertView.showAlert(title: "이미지를 불러오는데 실패했어요.",
                                            message: "재로그인 부탁드립니다.",
                                            viewController: self!,
                                            dismissAction: {
                            UserInfo.clearUserInfo()
                        })
                        
                    case .failure(let error):
                        AlertView.showAlert(title: "멤버 조회에 실패했어요.",
                                            message: "재로그인 부탁드립니다.",
                                            viewController: self!,
                                            dismissAction: {
                            UserInfo.clearUserInfo()
                            DispatchQueue.main.async {
                                UIViewController.changeRootVCToSignIn()
                            }
                        })
                    }
                }
                
                animationView.stop()
                animationView.removeFromSuperview()
            }
        })
        
        // 2. 목표 GET API
        //?month=\(selectedMonth)
        var getGoalPath = "/goal" + "/\(UserInfo.memberId)"
        
        if let currentYear = Global.shared.selectedYear {
            getGoalPath.append("?year=\(currentYear)")
        }
        if let currentMonth = Global.shared.selectedMonth {
            getGoalPath.append("&month=\(currentMonth)")
        }
        
        let requestGetGoal = APIRequest(method: .get,
                                        path: getGoalPath,
                                        param: nil,
                                        headers: APIConfig.authHeaders)
        APIService.shared.perform(request: requestGetGoal,
                                  completion: { (result) in
            switch result {
            case .success(let data):
                if let goal = data.body["data"] as? String {
                    if goal.count > 0 {
                        DispatchQueue.main.async {
                            self.goalTextFiled.text = goal
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            self.goalTextFiled.text = textViewPlaceHolder
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        self.goalTextFiled.text = textViewPlaceHolder
                    }
                }
            case .failure:
                print("🚩 목표 GET API Response Error : \(APIError.networkFailed)")
                DispatchQueue.main.async { [self] in
                    self.goalTextFiled.text = textViewPlaceHolder
                }
            }
        })
    }
}

// MARK: - CollectionView Handling
// CollectionView Cell data
extension HomeTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.reportImgList.count == 0 {
            self.emptyImgView.isHidden = false
        } else {
            self.emptyImgView.isHidden = true
        }
        return self.reportImgList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        // 역순 정렬 > 정정렬로 변경
        let reportData = self.reportImgList[indexPath.row]
        cell.cellImage.contentMode = .scaleAspectFill
        //        cell.cellImage.kf.setImage(with: URL(string:reportData.imagePath))
        // paging
        DispatchQueue.main.async {
            cell.cellImage.loadImage(urlString: reportData.imagePath)
        }
        return cell
    }
    
    // refactoring
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let boardVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadView") as? BoardViewController{
            self.navigationController?.pushViewController(boardVC, animated: true)
            boardVC.boardData =  self.reportImgList[indexPath.row]
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

extension HomeTabViewController: UITextViewDelegate {
    // 글자수 초과
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 목표 최대 글자수
        let maxCount = 13
        let newLength = textView.text.count - range.length + text.count
        let koreanMaxCount = maxCount + 1
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}

extension HomeTabViewController: CalendarViewDelegate {
    // 캘린더 선택 시 호출
    func customViewWillRemoveFromSuperview(_ customView: CalendarView) {
        DispatchQueue.main.async {
            self.titleLabel.text = "\u{1F5D3} \(Global.shared.selectedMonth!)월 소비기록"
            self.reportImgList = [BoardImage]()
            self.dataParsing(year: Global.shared.selectedYear
                             ,month: Global.shared.selectedMonth)
        }
    }
}
