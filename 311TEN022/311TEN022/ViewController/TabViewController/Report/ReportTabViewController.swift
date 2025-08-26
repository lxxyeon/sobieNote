//
//  ReportTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/19/23.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftUI
import Photos
import Lottie


// MARK: - TAB3. 보고서 화면
class ReportTabViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    private let disposebag = DisposeBag()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBarController?.tabBar.frame.size.height = 90
    }
    
    // MARK: - Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.calendarView.calendarSetup(type: 2)
        self.calendarView.delegate = self
        self.contentScrollView.delegate = self
        
        // 현재 날짜로 init
        self.dataParsing(selectedMonth: Global.shared.selectedMonth,
                         selectedYear: Global.shared.selectedYear)
        
        dateStackView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapStackView(sender:)))
        dateStackView.addGestureRecognizer(tap)
        
        bindViewModel()
        bindUI()
    }
    
    func bindUI() {
        monthButton.rx.tap
            .subscribe { _ in
                self.calendarView.calendarSetup(type: 2)
                self.currentButtonToggle = 2
                DispatchQueue.main.async {
                    self.monthButton.isSelected = true
                    self.yearButton.isSelected = false
                    self.dateLabel.text = Global.shared.selectedMonth + "월"
                }
            }
            .disposed(by: disposeBag)
        
        yearButton.rx.tap
            .subscribe { _ in
                self.calendarView.calendarSetup(type: 3)
                self.currentButtonToggle = 3
                DispatchQueue.main.async {
                    self.monthButton.isSelected = false
                    self.yearButton.isSelected = true
                    self.dateLabel.text = Global.shared.selectedYear + "년"
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        //        let selectedMonth = monthButton.rx.tap
        //            .map { _ in Global.shared.currentYear + "/" + Global.shared.selectedMonth }
        //
        //        let input = ReportViewModel.Input(
        //            selectedMonth: selectedMonth,
        //            yearButton: yearButton.rx.tap
        //        )
        //        let output = viewModel.transform(input: input)
        //
        //
        //        output.sortedCategoryValueSet
        //            .subscribe { list in
        //                <#code#>
        //            }
        //            .disposed(by: disposeBag)
        //
        //        // dateLabel
        //        output.date1
        //            .drive(onNext: { [weak self] date in
        //                self?.dateLabel.text = date
        //            })
        //            .disposed(by: disposebag)
        //
        //        output.date2
        //            .drive(onNext: { [weak self] date in
        //                self?.dateLabel.text = date
        //            })
        //            .disposed(by: disposebag)
    }
    
    // 최상단 월간/연간 버튼
    let buttonStackView: UIStackView = {
        let customStackView = UIStackView()
        customStackView.axis = .horizontal
        customStackView.alignment = .fill
        customStackView.distribution = .fillEqually
        customStackView.backgroundColor = .clear
        customStackView.translatesAutoresizingMaskIntoConstraints = false
        return customStackView
    }()
    
    // 월 선택 버튼
    let dateStackView: UIStackView = {
        let customStackView = UIStackView()
        customStackView.axis = .horizontal
        customStackView.alignment = .center
        customStackView.spacing = 10
        customStackView.distribution = .fill
        customStackView.backgroundColor = .clear
        customStackView.translatesAutoresizingMaskIntoConstraints = false
        return customStackView
    }()
    
    // MARK: UI Component
    private let calendarView = CalendarView()
    
    // scrollView
    private let contentScrollView: UIScrollView = {
        let customScrollView = UIScrollView()
        customScrollView.translatesAutoresizingMaskIntoConstraints = false
        return customScrollView
    }()
    
    // contentView
    private let contentView: UIView = {
        let customUIView = UIView()
        customUIView.translatesAutoresizingMaskIntoConstraints = false
        return customUIView
    }()
    
    var calendarIsHidden: Bool = true
    // init : 월(2)
    var currentButtonToggle = 2
    var index2 = 0
    var index3 = 0
    var sortedCategoryValueSet = [Int]()
    // 타이틀스택 클릭시 calendar 보여주는 action
    @objc func didTapStackView (sender: UITapGestureRecognizer) {
        if currentButtonToggle == 2 {
            calendarView.calendarSetup(type: 2)
        }else if currentButtonToggle == 3{
            calendarView.calendarSetup(type: 3)
        }
        
        if calendarIsHidden {
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(calendarView)
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: dateStackView.topAnchor, constant: dateStackView.frame.height),
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
    
    //1. 구매카테고리 report view - categories TagList1
    var categories = [ReportData]()
    var emotions = [ReportData]()
    var factors = [ReportData]()
    var satisfactions = [ReportData]()
    var satisfactionsAvg = 0
    
    func getSatisfactionsAvg() -> Int {
        var avg = 0
        var total = 0
        for satisfaction in satisfactions {
            avg = avg + Int(satisfaction.keyword)! * satisfaction.value
            total = total + satisfaction.value
        }
        return avg / total
    }
    
    func displayError(_ error: NSError?) {
        if let e = error {
            let alertController = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                // do nothing...
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    let disposeBag = DisposeBag()
    /// NW Response data parsing
    /// - Parameter selectedData: 선택 월/년 string 값
    func dataParsing(selectedMonth: String,
                     selectedYear: String) {
        self.categories = [ReportData]()
        self.emotions = [ReportData]()
        self.factors = [ReportData]()
        self.satisfactions = [ReportData]()
        self.satisfactionsAvg = 0
        
        let categoryURL = APIConfig.baseURL + "/report/categories" + "/\(selectedYear)/\(UserInfo.memberId)?month=\(selectedMonth)"
        let emotionURL =  APIConfig.baseURL + "/report/emotions" + "/\(selectedYear)/\(UserInfo.memberId)?month=\(selectedMonth)"
        let factorURL = APIConfig.baseURL + "/report/factors" + "/\(selectedYear)/\(UserInfo.memberId)?month=\(selectedMonth)"
        let satisfactionURL =  APIConfig.baseURL + "/report/satisfactions" + "/\(selectedYear)/\(UserInfo.memberId)?month=\(selectedMonth)"
        let satisfactionAvgURL =  APIConfig.baseURL + "/report/satisfactions/avg" + "/\(selectedYear)/\(UserInfo.memberId)?month=\(selectedMonth)"
        
        let categoryObservable = json(.get,
                                      categoryURL,
                                      headers: APIConfig.authHeaders)
        let emotionObservable = json(.get,
                                     emotionURL,
                                     headers: APIConfig.authHeaders)
        let factorObservable = json(.get,
                                    factorURL,
                                    headers: APIConfig.authHeaders)
        let satisfactionObservable = json(.get,
                                          satisfactionURL,
                                          headers: APIConfig.authHeaders)
        let satisfactionAvgObservable = json(.get,
                                             satisfactionAvgURL,
                                             headers: APIConfig.authHeaders)
        
        _ = Observable.zip(categoryObservable,
                           emotionObservable,
                           factorObservable,
                           satisfactionObservable,
                           satisfactionAvgObservable) { categoryJSON, emotionJSON, factorJSON, satisfactionJSON, satisfactionAvgJSON  in
            (categoryJSON, emotionJSON, factorJSON, satisfactionJSON, satisfactionAvgJSON)
        }
                           .subscribe(onNext: { categoryJSON, emotionJSON, factorJSON, satisfactionJSON, satisfactionAvgJSON in
                               let postInfo = NSMutableString()
                               
                               if let postDict = categoryJSON as? [String: AnyObject],
                                  let dataDict = postDict["data"] as? [[String:Any]]
                               {
                                   for data in dataDict{
                                       let responseReport = ReportData(keyword: data["keyword"] as! String,
                                                                       value: data["value_cnt"] as! Int)
                                       self.categories.append(responseReport)
                                   }
                               }
                               
                               if let postDict = emotionJSON as? [String: AnyObject],
                                  let dataDict = postDict["data"] as? [[String:Any]]
                               {
                                   for data in dataDict{
                                       let responseReport = ReportData(keyword: data["keyword"] as! String,
                                                                       value: data["value_cnt"] as! Int)
                                       self.emotions.append(responseReport)
                                   }
                               }
                               
                               if let postDict = factorJSON as? [String: AnyObject],
                                  let dataDict = postDict["data"] as? [[String:Any]]
                               {
                                   for data in dataDict{
                                       let responseReport = ReportData(keyword: data["keyword"] as! String,
                                                                       value: data["value_cnt"] as! Int)
                                       self.factors.append(responseReport)
                                   }
                               }
                               
                               if let postDict = satisfactionJSON as? [String: AnyObject],
                                  let dataDict = postDict["data"] as? [[String:Any]]
                               {
                                   for data in dataDict{
                                       let responseReport = ReportData(keyword: "\(data["keyword"])",
                                                                       value: data["value_cnt"] as! Int)
                                       self.satisfactions.append(responseReport)
                                   }
                               }
                               
                               if let postDict = satisfactionAvgJSON as? [String: AnyObject],
                                  let data = postDict["data"] as? Double
                               {
                                   self.satisfactionsAvg = Int(data)
                               }
                               // 카테고리 소팅
                               self.categories = self.categories.sorted(by: { $0.value > $1.value })
                               for category in self.categories {
                                   self.sortedCategoryValueSet.append(category.value)
                               }
                               self.sortedCategoryValueSet = Array(Set(self.sortedCategoryValueSet)).sorted(by: >)
                               
                               // 요소 소팅
                               self.factors = self.factors.sorted(by: { $0.value > $1.value })
                               emotionDataList.removeAll()
                               
                               if self.emotions.count > 0 {
                                   for emotion in self.emotions {
                                       if emotion.value > 0 {
                                           emotionDataList.append(EmotionData(emotion: emotion.keyword,
                                                                              amount: Double(emotion.value)))
                                       }
                                   }
                               }
                               if emotionDataList.count == 0 {
                                   emotionDataList.append(EmotionData(emotion: " ",
                                                                      amount: 0.0))
                               }
                               self.setReportUI()
                               
                           }, onError: { e in
                               print("error")
                               print(e)
                               //                self.dummyDataTextView.text = "An Error Occurred"
                               self.displayError(e as NSError)
                           }).disposed(by: disposeBag)
        
        
        
    }
    
    
    
    // 현재 년도에서만 가능
    //
    @objc func monthButtonAction(_ sender: UIButton){
        self.dataParsing(selectedMonth: Global.shared.selectedMonth,
                         selectedYear: Global.shared.selectedYear)
        
        //
        //        self.calendarView.calendarSetup(type: 2)
        //        self.currentButtonToggle = 2
        //        DispatchQueue.main.async {
        //            self.monthButton.isSelected = true
        //            self.yearButton.isSelected = false
        //            self.dateLabel.text = Global.shared.selectedMonth + "월"
        //        }
    }
    
    @objc func yearButtonAction(_ sender: UIButton){
        //        let url = "/" + Global.shared.selectedYear
        //        self.dataParsing(selectedData: url)
        //
        //        self.calendarView.calendarSetup(type: 3)
        //        self.currentButtonToggle = 3
        //        DispatchQueue.main.async {
        //            self.monthButton.isSelected = false
        //            self.yearButton.isSelected = true
        //            self.dateLabel.text = Global.shared.selectedYear + "년"
        //        }
    }
    
    // 보고서 앨범에 저장하기
    @objc func reportSaveToGalleryAction(_ sender: UIButton){
        guard let image = contentView.transfromToImage() else {
            return
        }
        // 앨범 저장
        PHPhotoLibrary.requestAuthorization( { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                DispatchQueue.main.async {
                    AlertView.showAlert(title: "보고서 저장 완료 😊",
                                        message: "앨범에 보고서를 저장했습니다",
                                        viewController: self,
                                        dismissAction: nil)
                }
            case .denied:
                // 권한 막혔을 때 처리 로직 추가
                break
            case .restricted, .notDetermined:
                break
            default:
                break
            }
        })
    }
    
    // 보고서 컨텐츠 공유하기
    @objc func reportShareAction(_ sender: UIButton){
        guard let image = contentView.transfromToImage() else {
            return
        }
        
        // 공유 하기
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.saveToCameraRoll]
        present(activityVC, animated: true)
    }
    
    let monthButton: CustomButton = {
        let customButton = CustomButton()
        customButton.isSelected = true
        customButton.setTitle("월간", for: .normal)
        customButton.titleLabel?.font = UIFont.kimB20()
        customButton.setTitleColor(.systemGray, for: .normal)
        customButton.setTitleColor(.black, for: .selected)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.addTarget(self, action: #selector(monthButtonAction(_:)), for: .touchUpInside)
        return customButton
    }()
    
    private let yearButton: CustomButton = {
        let customButton = CustomButton()
        customButton.setTitle("연간", for: .normal)
        customButton.setTitleColor(.systemGray, for: .normal)
        customButton.setTitleColor(.black, for: .selected)
        customButton.titleLabel?.font = UIFont.kimB20()
        customButton.addTarget(self, action: #selector(yearButtonAction(_:)), for: .touchUpInside)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        return customButton
    }()
    
    private let dateLabel: UILabel = {
        let customLabel = UILabel()
        //title 추후 수정
        customLabel.text = Global.shared.selectedMonth + "월"
        customLabel.textColor = .black
        customLabel.font = UIFont.kimB20()
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        return customLabel
    }()
    
    private let dateButton: UIButton = {
        let customButton = UIButton()
        customButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.tintColor = .black
        customButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        customButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
        return customButton
    }()
    
    // 2) 보고서 뷰
    
    // 3) 하단 버튼 스택 뷰
    private let bottomBtnView: UIView = {
        let bottomBtnView = UIView()
        bottomBtnView.translatesAutoresizingMaskIntoConstraints = false
        bottomBtnView.backgroundColor = .clear
        return bottomBtnView
    }()
    
    private let bottomBtnStackView: UIStackView = {
        let customStackView = UIStackView()
        customStackView.axis = .horizontal
        customStackView.alignment = .center
        customStackView.spacing = 10
        customStackView.distribution = .fillEqually
        customStackView.layer.cornerRadius = 20
        customStackView.backgroundColor = .systemGray6
        customStackView.translatesAutoresizingMaskIntoConstraints = false
        return customStackView
    }()
    
    private let bottomHalfLineView: UIView = {
        let customView = UIView()
        customView.backgroundColor = .systemGray4
        customView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        customView.translatesAutoresizingMaskIntoConstraints = false
        return customView
    }()
    
    // 앨범 내 저장하기 버튼
    private let saveToAlbumBtn: UIButton = {
        let customButton = UIButton()
        customButton.clipsToBounds = true
        customButton.layer.cornerRadius = 3
        customButton.titleLabel?.font = UIFont.kimR15()
        customButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        customButton.tintColor = .darkGray
        customButton.setTitle("  저장하기", for: .normal)
        customButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        customButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        customButton.setTitleColor(.darkGray, for: .normal)
        customButton.setBackgroundColor(.clear, for: .normal)
        customButton.addTarget(self, action: #selector(reportSaveToGalleryAction(_:)), for: .touchUpInside)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        return customButton
    }()
    
    // 보고서 공유하기 버튼
    private let reportShareToContentBtn: UIButton = {
        let customButton = UIButton()
        customButton.clipsToBounds = true
        customButton.layer.cornerRadius = 3
        customButton.titleLabel?.font = UIFont.kimR15()
        customButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        customButton.tintColor = .darkGray
        customButton.setTitle("  공유하기", for: .normal)
        customButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        customButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        customButton.setTitleColor(.darkGray, for: .normal)
        customButton.setBackgroundColor(.clear, for: .normal)
        customButton.addTarget(self, action: #selector(reportShareAction(_:)), for: .touchUpInside)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        return customButton
    }()
    
    // MARK: UI Component Setup
    func setupUI(){
        // 1) 상단 월/연 선택 버튼 스택 뷰 Setup
        buttonStackView.addArrangedSubview(monthButton)
        buttonStackView.addArrangedSubview(yearButton)
        
        self.view.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(dateButton)
        
        self.view.addSubview(dateStackView)
        
        NSLayoutConstraint.activate([
            dateStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            dateStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 15),
            dateStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // 2) 보고서 뷰 Setup
        self.view.addSubview(self.contentScrollView)
        self.contentScrollView.addSubview(self.contentView)
        
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: 30),
            self.contentScrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.contentScrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            self.contentView.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor),
            self.contentView.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor),
            self.contentView.heightAnchor.constraint(equalToConstant: 1500),
            
        ])
        
        contentView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor).isActive = true
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        // 3) 하단 버튼 스택 뷰 Setup
        bottomBtnStackView.addArrangedSubview(saveToAlbumBtn)
        bottomBtnStackView.addArrangedSubview(reportShareToContentBtn)
        
        bottomBtnView.addSubview(bottomBtnStackView)
        bottomBtnView.addSubview(bottomHalfLineView)
        
        self.contentScrollView.addSubview(self.bottomBtnView)
        NSLayoutConstraint.activate([
            self.bottomBtnView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.bottomBtnView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            self.bottomBtnView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.bottomBtnView.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            self.bottomBtnView.heightAnchor.constraint(equalToConstant: 60),
        ])
        NSLayoutConstraint.activate([
            bottomHalfLineView.centerXAnchor.constraint(equalTo: bottomBtnView.centerXAnchor),
            bottomHalfLineView.topAnchor.constraint(equalTo: self.bottomBtnView.safeAreaLayoutGuide.topAnchor, constant: 20),
            bottomHalfLineView.bottomAnchor.constraint(equalTo: self.bottomBtnView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bottomHalfLineView.widthAnchor.constraint(equalToConstant: 10),
            bottomBtnStackView.leadingAnchor.constraint(equalTo: bottomBtnView.leadingAnchor, constant: 30),
            bottomBtnStackView.trailingAnchor.constraint(equalTo: self.bottomBtnView.trailingAnchor, constant: -30),
            bottomBtnStackView.topAnchor.constraint(equalTo: self.bottomBtnView.safeAreaLayoutGuide.topAnchor),
            bottomBtnStackView.bottomAnchor.constraint(equalTo: bottomBtnView.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func factorRankSorting(index: Int) -> Int{
        if index > 0 && self.factors[index].value == self.factors[index-1].value {
            return factorRankSorting(index: index-1)
        }
        return index+1
    }
    
    func setReportUI() {
        //base view
        let graphView = ReportUIView()
        
        // 1. 구매카테고리 report view - categories TagList1
        let subGraphView1: UIView = {
            let customUIView = UIView()
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        
        //왼쪽 카테고리 스택
        let categoryStackView1: UIStackView = {
            let customStackView = UIStackView()
            customStackView.axis = .vertical
            customStackView.alignment = .fill
            customStackView.distribution = .fillEqually
            customStackView.spacing = 6
            customStackView.contentMode = .scaleToFill
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
        
        let categoryStackView2: UIStackView = {
            let customStackView = UIStackView()
            customStackView.axis = .vertical
            customStackView.alignment = .fill
            customStackView.distribution = .fillEqually
            customStackView.spacing = 6
            customStackView.contentMode = .scaleToFill
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
        
        for i in 0..<7{
            //카테고리 타이틀
            let categoryTitleLabel: UILabel = {
                let customLabel = UILabel()
                customLabel.text = self.categories[i].keyword
                //                customLabel.backgroundColor = .black
                customLabel.textColor = .black
                customLabel.font = UIFont.kimR16()
                customLabel.textAlignment = .left
                customLabel.sizeToFit()
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                return customLabel
            }()
            
            //카테고리 값
            let categoryValueLabel: UILabel = {
                let customLabel = UILabel()
                customLabel.text = "0"
                for category in self.categories {
                    if categoryTitleLabel.text == category.keyword{
                        customLabel.text = "\(category.value)"
                    }
                }
                customLabel.textColor = .black
                customLabel.font = UIFont.kimR17()
                customLabel.textAlignment = .right
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                customLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
                return customLabel
            }()
            
            let categoryLabelStackView: UIStackView = {
                let customStackView = UIStackView()
                customStackView.axis = .horizontal
                customStackView.alignment = .fill
                customStackView.distribution = .fill
                customStackView.backgroundColor = .clear
                customStackView.contentMode = .scaleToFill
                customStackView.translatesAutoresizingMaskIntoConstraints = false
                return customStackView
            }()
            // 값이 max
            if (categories[i].value == sortedCategoryValueSet[0]){
                let rankImage: UIImageView = {
                    let customImage = UIImageView()
                    customImage.image = UIImage(named: "rank1")
                    customImage.contentMode = .scaleAspectFit
                    customImage.translatesAutoresizingMaskIntoConstraints = false
                    customImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    customImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
                    return customImage
                }()
                let categoryRankStackView: UIStackView = {
                    let customStackView = UIStackView()
                    customStackView.axis = .horizontal
                    customStackView.alignment = .center
                    customStackView.distribution = .fill
                    customStackView.spacing = 5
                    customStackView.backgroundColor = .clear
                    customStackView.contentMode = .scaleToFill
                    customStackView.translatesAutoresizingMaskIntoConstraints = false
                    return customStackView
                }()
                categoryRankStackView.addArrangedSubview(rankImage)
                categoryRankStackView.addArrangedSubview(categoryTitleLabel)
                NSLayoutConstraint.activate([
                    rankImage.leadingAnchor.constraint(equalTo: categoryRankStackView.leadingAnchor, constant: -5)
                ])
                categoryLabelStackView.addArrangedSubview(categoryRankStackView)
            }
            else if (sortedCategoryValueSet.count > 1 && categories[i].value == sortedCategoryValueSet[1] && categories[i].value > 0){
                let rankImage: UIImageView = {
                    let customImage = UIImageView()
                    customImage.image = UIImage(named: "rank2")
                    customImage.contentMode = .scaleAspectFit
                    customImage.translatesAutoresizingMaskIntoConstraints = false
                    customImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    customImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
                    return customImage
                }()
                let categoryRankStackView: UIStackView = {
                    let customStackView = UIStackView()
                    customStackView.axis = .horizontal
                    customStackView.alignment = .center
                    customStackView.distribution = .fill
                    customStackView.spacing = 5
                    customStackView.backgroundColor = .clear
                    customStackView.contentMode = .scaleToFill
                    customStackView.translatesAutoresizingMaskIntoConstraints = false
                    return customStackView
                }()
                categoryRankStackView.addArrangedSubview(rankImage)
                categoryRankStackView.addArrangedSubview(categoryTitleLabel)
                NSLayoutConstraint.activate([
                    rankImage.leadingAnchor.constraint(equalTo: categoryRankStackView.leadingAnchor, constant: -5)
                ])
                categoryLabelStackView.addArrangedSubview(categoryRankStackView)
            }
            else if (sortedCategoryValueSet.count > 2 && categories[i].value == sortedCategoryValueSet[2] && categories[i].value > 0){
                let rankImage: UIImageView = {
                    let customImage = UIImageView()
                    customImage.image = UIImage(named: "rank3")
                    customImage.contentMode = .scaleAspectFit
                    customImage.translatesAutoresizingMaskIntoConstraints = false
                    customImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    customImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
                    return customImage
                }()
                let categoryRankStackView: UIStackView = {
                    let customStackView = UIStackView()
                    customStackView.axis = .horizontal
                    customStackView.alignment = .center
                    customStackView.distribution = .fill
                    customStackView.spacing = 5
                    customStackView.backgroundColor = .clear
                    customStackView.contentMode = .scaleToFill
                    customStackView.translatesAutoresizingMaskIntoConstraints = false
                    return customStackView
                }()
                categoryRankStackView.addArrangedSubview(rankImage)
                categoryRankStackView.addArrangedSubview(categoryTitleLabel)
                NSLayoutConstraint.activate([
                    rankImage.leadingAnchor.constraint(equalTo: categoryRankStackView.leadingAnchor, constant: -5)
                ])
                categoryLabelStackView.addArrangedSubview(categoryRankStackView)
            }
            
            else{
                categoryLabelStackView.addArrangedSubview(categoryTitleLabel)
            }
            categoryLabelStackView.addArrangedSubview(categoryValueLabel)
            categoryStackView1.addArrangedSubview(categoryLabelStackView)
        }
        
        for i in 7..<14{
            //카테고리 타이틀
            let categoryTitleLabel: UILabel = {
                let customLabel = UILabel()
                //title 추후 수정
                customLabel.text = self.categories[i].keyword
                customLabel.textColor = .black
                customLabel.font = UIFont.kimR17()
                customLabel.textAlignment = .left
                customLabel.sizeToFit()
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                return customLabel
            }()
            
            //카테고리 값
            let categoryValueLabel: UILabel = {
                let customLabel = UILabel()
                //title 추후 수정
                customLabel.text = "0"
                for category in self.categories {
                    if categoryTitleLabel.text == category.keyword{
                        customLabel.text = "\(category.value)"
                    }
                }
                customLabel.textColor = .black
                customLabel.font = UIFont.kimR17()
                customLabel.textAlignment = .right
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                customLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
                return customLabel
            }()
            
            let categoryLabelStackView: UIStackView = {
                let customStackView = UIStackView()
                customStackView.axis = .horizontal
                customStackView.alignment = .fill
                customStackView.distribution = .fill
                customStackView.backgroundColor = .clear
                customStackView.contentMode = .scaleToFill
                customStackView.translatesAutoresizingMaskIntoConstraints = false
                return customStackView
            }()
            //            categoryLabelStackView.addArrangedSubview(categoryTitleLabel)
            if (categories[i].value == sortedCategoryValueSet[0]){
                let rankImage: UIImageView = {
                    let customImage = UIImageView()
                    customImage.image = UIImage(named: "rank1")
                    customImage.contentMode = .scaleAspectFit
                    customImage.translatesAutoresizingMaskIntoConstraints = false
                    customImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    customImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
                    return customImage
                }()
                let categoryRankStackView: UIStackView = {
                    let customStackView = UIStackView()
                    customStackView.axis = .horizontal
                    customStackView.alignment = .center
                    customStackView.distribution = .fill
                    customStackView.spacing = 5
                    customStackView.backgroundColor = .clear
                    customStackView.contentMode = .scaleToFill
                    customStackView.translatesAutoresizingMaskIntoConstraints = false
                    return customStackView
                }()
                categoryRankStackView.addArrangedSubview(rankImage)
                categoryRankStackView.addArrangedSubview(categoryTitleLabel)
                NSLayoutConstraint.activate([
                    rankImage.leadingAnchor.constraint(equalTo: categoryRankStackView.leadingAnchor, constant: -5)
                ])
                categoryLabelStackView.addArrangedSubview(categoryRankStackView)
            }
            else if (sortedCategoryValueSet.count > 1 && categories[i].value == sortedCategoryValueSet[1] && categories[i].value > 0){
                let rankImage: UIImageView = {
                    let customImage = UIImageView()
                    customImage.image = UIImage(named: "rank2")
                    customImage.contentMode = .scaleAspectFit
                    customImage.translatesAutoresizingMaskIntoConstraints = false
                    customImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    customImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
                    return customImage
                }()
                let categoryRankStackView: UIStackView = {
                    let customStackView = UIStackView()
                    customStackView.axis = .horizontal
                    customStackView.alignment = .center
                    customStackView.distribution = .fill
                    customStackView.spacing = 5
                    customStackView.backgroundColor = .clear
                    customStackView.contentMode = .scaleToFill
                    customStackView.translatesAutoresizingMaskIntoConstraints = false
                    return customStackView
                }()
                categoryRankStackView.addArrangedSubview(rankImage)
                categoryRankStackView.addArrangedSubview(categoryTitleLabel)
                NSLayoutConstraint.activate([
                    rankImage.leadingAnchor.constraint(equalTo: categoryRankStackView.leadingAnchor, constant: -5)
                ])
                categoryLabelStackView.addArrangedSubview(categoryRankStackView)
            }
            else if (sortedCategoryValueSet.count > 2 && categories[i].value == sortedCategoryValueSet[2] && categories[i].value > 0){
                let rankImage: UIImageView = {
                    let customImage = UIImageView()
                    customImage.image = UIImage(named: "rank3")
                    customImage.contentMode = .scaleAspectFit
                    customImage.translatesAutoresizingMaskIntoConstraints = false
                    customImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    customImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
                    return customImage
                }()
                let categoryRankStackView: UIStackView = {
                    let customStackView = UIStackView()
                    customStackView.axis = .horizontal
                    customStackView.alignment = .center
                    customStackView.distribution = .fill
                    customStackView.spacing = 5
                    customStackView.backgroundColor = .clear
                    customStackView.contentMode = .scaleToFill
                    customStackView.translatesAutoresizingMaskIntoConstraints = false
                    return customStackView
                }()
                categoryRankStackView.addArrangedSubview(rankImage)
                categoryRankStackView.addArrangedSubview(categoryTitleLabel)
                NSLayoutConstraint.activate([
                    rankImage.leadingAnchor.constraint(equalTo: categoryRankStackView.leadingAnchor, constant: -5)
                ])
                categoryLabelStackView.addArrangedSubview(categoryRankStackView)
            }
            else{
                categoryLabelStackView.addArrangedSubview(categoryTitleLabel)
            }
            categoryLabelStackView.addArrangedSubview(categoryValueLabel)
            categoryStackView2.addArrangedSubview(categoryLabelStackView)
        }
        
        //카테고리 순위 가운데 선
        let centerLineView: UIView = {
            let customUIView = UIView()
            customUIView.backgroundColor = .lightGray
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        
        subGraphView1.addSubview(categoryStackView1)
        subGraphView1.addSubview(centerLineView)
        subGraphView1.addSubview(categoryStackView2)
        
        NSLayoutConstraint.activate([
            categoryStackView1.topAnchor.constraint(equalTo: subGraphView1.topAnchor, constant: 30),
            categoryStackView1.leadingAnchor.constraint(equalTo: subGraphView1.leadingAnchor, constant: 10),
            categoryStackView1.bottomAnchor.constraint(equalTo: subGraphView1.bottomAnchor, constant: -50),
            categoryStackView1.trailingAnchor.constraint(equalTo: subGraphView1.centerXAnchor, constant: -30),
            
            centerLineView.centerXAnchor.constraint(equalTo: subGraphView1.centerXAnchor),
            centerLineView.topAnchor.constraint(equalTo: subGraphView1.topAnchor, constant: 30),
            centerLineView.bottomAnchor.constraint(equalTo: subGraphView1.bottomAnchor, constant: -50),
            centerLineView.widthAnchor.constraint(equalToConstant: 1),
            
            categoryStackView2.topAnchor.constraint(equalTo: subGraphView1.topAnchor, constant: 30),
            categoryStackView2.trailingAnchor.constraint(equalTo: subGraphView1.trailingAnchor, constant: -10),
            categoryStackView2.bottomAnchor.constraint(equalTo: subGraphView1.bottomAnchor, constant: -50),
            categoryStackView2.leadingAnchor.constraint(equalTo: subGraphView1.centerXAnchor, constant: 30),
        ])
        let graphView1 = graphView.reportBaseView(title: Tags.TagTitleList[0], graph: subGraphView1, bottomIs: true)
        
        
        // 2. 감정리포트 : emotions report view - emotions TagList2
        let subGraphView2: UIView = {
            var customUIView = UIView()
            //            emotionDataList.removeAll()
            //            if self.emotions.count > 0 {
            //                for emotion in self.emotions {
            //                    if emotion.value > 0 {
            //                        emotionDataList.append(EmotionData(emotion: emotion.keyword,
            //                                                           amount: Double(emotion.value)))
            //                    }
            //                }
            //            }else{
            //                // 데이터 없는 경우init value
            //                emotionDataList.append(EmotionData(emotion: " ",
            //                                                   amount: 0.0))
            //            }
            
            let pie = PieChartView().backgroundStyle(.clear)
            if let pieView = UIHostingController(rootView: pie
                .frame(width: 400, height: 200))
                .view {
                customUIView = pieView
            }
            customUIView.backgroundColor = .clear
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        let graphView2 = graphView.reportBaseView(title: Tags.TagTitleList[1],
                                                  graph: subGraphView2,
                                                  bottomIs: true)
        
        //3. 구매요인 report view - factors TagList3
        let subGraphView3: UIView = {
            let customUIView = UIView()
            customUIView.backgroundColor = .clear
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        
        // 세로 스택
        let emotionStackView: UIStackView = {
            let customStackView = UIStackView()
            customStackView.axis = .vertical
            customStackView.alignment = .fill
            customStackView.distribution = .fillEqually
            customStackView.spacing = 20
            customStackView.contentMode = .scaleToFill
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
        
        // 순위 스택 = 넘버+요소 스택 + 벨류 라벨
        for i in 0..<5 {
            // index별 동순위 처리
            let rankValue = factorRankSorting(index: i)
            
            let numberButton: UIButton = {
                let customButton = UIButton()
                customButton.clipsToBounds = true
                customButton.layer.cornerRadius = 3
                //                if rankValue == 1 {
                customButton.titleLabel?.font = UIFont.kimB16()
                customButton.setTitle("\(rankValue)", for: .normal)
                customButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
                customButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
                customButton.setTitleColor(.white, for: .normal)
                customButton.setBackgroundColor(.init(hexCode: Global.PointColorHexCode), for: .normal)
                customButton.translatesAutoresizingMaskIntoConstraints = false
                return customButton
            }()
            
            let emotionTitleLabel: UILabel = {
                let customlabel = UILabel()
                if self.factors.count > 0 && self.factors.count > i{
                    customlabel.text = self.factors[i].keyword
                }else{
                    customlabel.text = "-"
                }
                if rankValue == 1 {
                    customlabel.font = UIFont.kimB18()
                }else{
                    customlabel.font = UIFont.kimR17()
                }
                customlabel.lineBreakMode = .byWordWrapping
                customlabel.translatesAutoresizingMaskIntoConstraints = false
                return customlabel
            }()
            
            // 넘버+요소 스택
            let numberLabelStackView: UIStackView = {
                let customStackView = UIStackView()
                customStackView.axis = .horizontal
                customStackView.spacing = 25
                customStackView.alignment = .center
                customStackView.distribution = .fill
                customStackView.backgroundColor = .clear
                customStackView.contentMode = .scaleToFill
                customStackView.translatesAutoresizingMaskIntoConstraints = false
                return customStackView
            }()
            
            numberLabelStackView.addArrangedSubview(numberButton)
            numberLabelStackView.addArrangedSubview(emotionTitleLabel)
            
            let emotionValueLabel: UILabel = {
                let customlabel = UILabel()
                if self.factors.count > 0 && self.factors.count > i{
                    customlabel.text = "\(self.factors[i].value)"
                }else{
                    customlabel.text = "0"
                }
                if rankValue == 1 {
                    customlabel.font = UIFont.kimB18()
                }else{
                    customlabel.font = UIFont.kimR17()
                }
                customlabel.lineBreakMode = .byWordWrapping
                customlabel.translatesAutoresizingMaskIntoConstraints = false
                return customlabel
            }()
            
            // 가로 스택
            let horizonLabelStackView: UIStackView = {
                let customStackView = UIStackView()
                customStackView.axis = .horizontal
                customStackView.alignment = .fill
                customStackView.distribution = .fill
                customStackView.backgroundColor = .clear
                customStackView.contentMode = .scaleToFill
                customStackView.translatesAutoresizingMaskIntoConstraints = false
                return customStackView
            }()
            
            horizonLabelStackView.addArrangedSubview(numberLabelStackView)
            horizonLabelStackView.addArrangedSubview(emotionValueLabel)
            emotionStackView.addArrangedSubview(horizonLabelStackView)
        }
        
        subGraphView3.addSubview(emotionStackView)
        NSLayoutConstraint.activate([
            emotionStackView.bottomAnchor.constraint(equalTo: subGraphView3.bottomAnchor, constant: -66),
            emotionStackView.centerXAnchor.constraint(equalTo: subGraphView3.centerXAnchor),
            emotionStackView.widthAnchor.constraint(equalToConstant: 240)
        ])
        let graphView3 = graphView.reportBaseView(title: Tags.TagTitleList[2], graph: subGraphView3, bottomIs: true)
        
        
        //4. 구매만족도 report view - satisfactions TagList4
        let subGraphView4: UIView = {
            var customUIView = UIView()
            //line 그래프로 변경
            let pie = HalfPieView(progress: CGFloat(self.satisfactionsAvg)).backgroundStyle(.clear)
            if let pieView = UIHostingController(rootView: pie
                .frame(width: 400, height: 400))
                .view {
                customUIView = pieView
            }
            customUIView.backgroundColor = .clear
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        
        // 구매만족도 bar graph
        let barGraphBaseView: UIView = {
            let baseView = UIView()
            baseView.backgroundColor = .clear
            baseView.layer.cornerRadius = 10
            baseView.translatesAutoresizingMaskIntoConstraints = false
            return baseView
        }()
        
        let barBGView: UIView = {
            let baseView = UIView()
            baseView.layer.cornerRadius = 10
            baseView.backgroundColor = .systemGray5
            baseView.translatesAutoresizingMaskIntoConstraints = false
            return baseView
        }()
        
        //        weak var barView: UIView! {
        //            didSet{
        //                barView.layer.cornerRadius = 10
        //                barView.setGradient(color1: .black, color2: .blue)
        //                barView.translatesAutoresizingMaskIntoConstraints = false
        //            }
        //        }
        //
        let barView: GradientView = {
            let baseView = GradientView()
            //            baseView.backgroundColor = UIColor(hexCode: Global.PointColorHexCode)
            baseView.layer.cornerRadius = 10
            //            baseView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
            baseView.setNeedsLayout()
            //            baseView.setGradientViewGradient(color1: .blue, color2: .black)
            baseView.translatesAutoresizingMaskIntoConstraints = false
            return baseView
        }()
        
        let barTitleView: UILabel = {
            let customlabel = UILabel()
            customlabel.text = "\(self.satisfactionsAvg)" + "%"
            customlabel.font = UIFont.kimB19()
            customlabel.textColor = .white
            customlabel.lineBreakMode = .byWordWrapping
            customlabel.textAlignment = .center
            customlabel.translatesAutoresizingMaskIntoConstraints = false
            return customlabel
        }()
        
        
        barBGView.addSubview(barView)
        barGraphBaseView.addSubview(barBGView)
        barView.addSubview(barTitleView)
        
        NSLayoutConstraint.activate([
            barBGView.centerXAnchor.constraint(equalTo: barGraphBaseView.centerXAnchor),
            barBGView.centerYAnchor.constraint(equalTo: barGraphBaseView.centerYAnchor),
            barBGView.widthAnchor.constraint(equalToConstant: 70),
            barBGView.heightAnchor.constraint(equalToConstant: 180),
            
            barView.centerXAnchor.constraint(equalTo: barBGView.centerXAnchor),
            barView.bottomAnchor.constraint(equalTo: barBGView.bottomAnchor),
            barView.widthAnchor.constraint(equalToConstant: 70),
            // 그래프 비율로 계산한 유동 값
            barView.heightAnchor.constraint(equalToConstant: CGFloat(self.satisfactionsAvg * 180 / 100)),
            
            barTitleView.centerXAnchor.constraint(equalTo: barBGView.centerXAnchor),
            barTitleView.topAnchor.constraint(equalTo: barView.topAnchor, constant: 9),
            barTitleView.widthAnchor.constraint(equalToConstant: 50),
            barTitleView.heightAnchor.constraint(equalToConstant: 22),
        ])
        
        // 구매만족도 percent 세로 스택
        let percentStackView: UIStackView = {
            let customStackView = UIStackView()
            customStackView.axis = .vertical
            customStackView.alignment = .fill
            customStackView.distribution = .fillEqually
            customStackView.contentMode = .scaleToFill
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
        
        //stack in stack
        for i in 0..<5{
            let percentTitleLabel: UILabel = {
                let customlabel = UILabel()
                customlabel.text = Tags.TagList4[i] + "%"
                customlabel.font = UIFont.kimR16()
                customlabel.lineBreakMode = .byWordWrapping
                customlabel.translatesAutoresizingMaskIntoConstraints = false
                return customlabel
            }()
            
            let percentValueLabel: UILabel = {
                let customlabel = UILabel()
                customlabel.text = "0"
                for satisfaction in self.satisfactions {
                    if String((percentTitleLabel.text?.dropLast())!) == satisfaction.keyword{
                        customlabel.text = "\(satisfaction.value)"
                    }
                }
                customlabel.textAlignment = .center
                customlabel.font = UIFont.kimR16()
                customlabel.lineBreakMode = .byWordWrapping
                customlabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
                customlabel.translatesAutoresizingMaskIntoConstraints = false
                return customlabel
            }()
            
            //넘버 스택
            let percentLabelStackView: UIStackView = {
                let customStackView = UIStackView()
                customStackView.axis = .horizontal
                customStackView.spacing = 55
                customStackView.alignment = .center
                customStackView.distribution = .fill
                customStackView.backgroundColor = .clear
                customStackView.contentMode = .scaleToFill
                customStackView.translatesAutoresizingMaskIntoConstraints = false
                return customStackView
            }()
            
            percentLabelStackView.addArrangedSubview(percentTitleLabel)
            percentLabelStackView.addArrangedSubview(percentValueLabel)
            percentStackView.addArrangedSubview(percentLabelStackView)
        }
        
        //        subGraphView4.addSubview(barGraphBaseView)
        //        subGraphView4.addSubview(percentStackView)
        //
        //        NSLayoutConstraint.activate([
        //            barGraphBaseView.leadingAnchor.constraint(equalTo: subGraphView4.leadingAnchor),
        //            barGraphBaseView.bottomAnchor.constraint(equalTo: subGraphView4.bottomAnchor),
        //            barGraphBaseView.topAnchor.constraint(equalTo: subGraphView4.topAnchor),
        //            barGraphBaseView.trailingAnchor.constraint(equalTo: subGraphView4.centerXAnchor),
        //
        //            percentStackView.leadingAnchor.constraint(equalTo: subGraphView4.centerXAnchor, constant: 20),
        //            percentStackView.centerYAnchor.constraint(equalTo: subGraphView4.centerYAnchor),
        //            percentStackView.heightAnchor.constraint(equalToConstant: 165)
        //        ])
        //
        let graphView4 = graphView.reportBaseView(title: Tags.TagTitleList[3],
                                                  graph: subGraphView4,
                                                  bottomIs: false)
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        contentView.addSubview(graphView1)
        contentView.addSubview(graphView2)
        contentView.addSubview(graphView3)
        contentView.addSubview(graphView4)
        
        NSLayoutConstraint.activate([
            graphView1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            graphView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            graphView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            graphView1.heightAnchor.constraint(equalToConstant: 350),
            
            graphView2.topAnchor.constraint(equalTo: graphView1.safeAreaLayoutGuide.bottomAnchor, constant: 35),
            graphView2.leadingAnchor.constraint(equalTo: graphView1.safeAreaLayoutGuide.leadingAnchor),
            graphView2.trailingAnchor.constraint(equalTo: graphView1.safeAreaLayoutGuide.trailingAnchor),
            graphView2.heightAnchor.constraint(equalToConstant: 350),
            
            graphView3.topAnchor.constraint(equalTo: graphView2.safeAreaLayoutGuide.bottomAnchor, constant: 35),
            graphView3.leadingAnchor.constraint(equalTo: graphView2.safeAreaLayoutGuide.leadingAnchor),
            graphView3.trailingAnchor.constraint(equalTo: graphView2.safeAreaLayoutGuide.trailingAnchor),
            graphView3.heightAnchor.constraint(equalToConstant: 350),
            
            graphView4.topAnchor.constraint(equalTo: graphView3.safeAreaLayoutGuide.bottomAnchor, constant: 35),
            graphView4.leadingAnchor.constraint(equalTo: graphView3.safeAreaLayoutGuide.leadingAnchor),
            graphView4.trailingAnchor.constraint(equalTo: graphView3.safeAreaLayoutGuide.trailingAnchor),
            graphView4.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
        //        barView.setGradient(color1: .black, color2: .blue)
        
    }
    //    func entryData(dataPoints: [String], values: [Double]) -> [ChartDataEntry] {
    //        // entry 담을 array
    //        var pieDataEntries: [ChartDataEntry] = []
    //        // 담기
    //        for i in 0 ..< values.count {
    //            let pieDataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data:  dataPoints[i] as AnyObject)
    //            pieDataEntries.append(pieDataEntry)
    //        }
    //        // 반환
    //        return pieDataEntries
    //    }
    //    func setPieData(pieChartView: PieChartView, pieChartDataEntries: [ChartDataEntry]) {
    //        // Entry들을 이용해 Data Set 만들기
    //        let pieChartdataSet = PieChartDataSet(entries: pieChartDataEntries)
    //        pieChartdataSet.sliceSpace = 1    //항목간 간격
    //        pieChartdataSet.colors = [UIColor(hexCode: "343C19"),
    //                                  UIColor(hexCode: "8D8E8A"),
    //                                  UIColor(hexCode: "AEAFAC"),
    //                                  UIColor(hexCode: "E6E6E5"),
    //                                  UIColor(hexCode: "F2F3F2")]
    //
    //        // DataSet을 차트 데이터로 넣기
    //        let pieChartData = PieChartData(dataSet: pieChartdataSet)
    //        // 데이터 출력
    //        pieChartView.data = pieChartData
    //    }
    
}

class GradientView: UIView {
    var gradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
        gradient.cornerRadius = self.layer.cornerRadius
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGradientView(){
        gradient.colors = [UIColor(hexCode: Global.PointColorHexCode).cgColor,
                           UIColor(hexCode: Global.PointColorHexCode).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.addSublayer(gradient)
    }
}

class ReportUIView: UIView {
    private func setUI(){
        self.reportBaseView(title: "test",
                            graph: UIView(),
                            bottomIs: true)
    }
    
    func reportBaseView(title: String,
                        graph: UIView,
                        bottomIs: Bool) -> UIView {
        // 그래프 타이틀
        let titleLabel: UILabel = {
            let customlabel = UILabel()
            customlabel.text = title
            customlabel.font = UIFont.kimB20()
            customlabel.lineBreakMode = .byWordWrapping
            customlabel.translatesAutoresizingMaskIntoConstraints = false
            return customlabel
        }()
        
        // 하단 라인
        let bottomLineView: UIView = {
            let customView = UIView()
            customView.backgroundColor = UIColor(hexCode: "C7C8C6")
            customView.translatesAutoresizingMaskIntoConstraints = false
            return customView
        }()
        
        // base View
        let reportView: UIView = {
            let customView = UIView()
            customView.backgroundColor = .clear
            customView.translatesAutoresizingMaskIntoConstraints = false
            return customView
        }()
        
        reportView.addSubview(titleLabel)
        reportView.addSubview(graph)
        if (bottomIs) {
            reportView.addSubview(bottomLineView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: reportView.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: reportView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: reportView.trailingAnchor),
            
        ])
        if (!bottomIs) {
            NSLayoutConstraint.activate([
                //graph constraint 주기
                graph.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 70),
                graph.leadingAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.leadingAnchor),
                graph.trailingAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.trailingAnchor),
                graph.bottomAnchor.constraint(equalTo: reportView.bottomAnchor)
            ])
        }else{
            // 아래 리포트가 더 있는 경우
            NSLayoutConstraint.activate([
                graph.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 10),
                graph.leadingAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.leadingAnchor),
                graph.trailingAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.trailingAnchor),
                graph.bottomAnchor.constraint(equalTo: bottomLineView.topAnchor, constant: -10),
                
                bottomLineView.heightAnchor.constraint(equalToConstant: 2),
                bottomLineView.leadingAnchor.constraint(equalTo: reportView.leadingAnchor),
                bottomLineView.trailingAnchor.constraint(equalTo: reportView.trailingAnchor),
                bottomLineView.bottomAnchor.constraint(equalTo: reportView.bottomAnchor)  ])
        }
        
        
        return reportView
    }
}

extension ReportTabViewController: CalendarViewDelegate {
    func customViewWillRemoveFromSuperview(_ customView: CalendarView) {
        
        var url = "/" + Global.shared.selectedYear
        
        //월간 리포트
        if customView.type == 2 {
            DispatchQueue.main.async {
                self.dateLabel.text = Global.shared.selectedMonth + "월"
            }
            url = url + "/" + Global.shared.selectedMonth
        }else{
            //연간 리포트
            DispatchQueue.main.async {
                //                self.dateLabel.text = Global.shared.selectedYear + "년"
            }
        }
        
        self.dataParsing(selectedMonth: Global.shared.selectedMonth,
                         selectedYear: Global.shared.selectedYear)
    }
    
}

class CustomButton: UIButton {
    override var isSelected: Bool {
        didSet {
            updateBottomBorder()
        }
    }
    
    private let bottomBorderLayer: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 1
        layer.backgroundColor = UIColor(hexCode: Global.PointColorHexCode).cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.addSublayer(bottomBorderLayer)
        updateBottomBorder()
    }
    
    private func updateBottomBorder() {
        bottomBorderLayer.frame = CGRect.init(x: 0, y: frame.height - 3, width: frame.width, height: 3)
        bottomBorderLayer.isHidden = !isSelected
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBottomBorder()
    }
}
