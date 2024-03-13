//
//  ReportTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/19/23.
//

import UIKit
//import DGCharts
import Lottie
import RxSwift
import RxAlamofire
//import SwiftUICharts
import SwiftUI

// TAB3. 보고서 화면
class ReportTabViewController: UIViewController, UIScrollViewDelegate {
    //최상단 월간/연간 버튼
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
    
    let calendarView = CalendarView()
    var calendarIsHidden: Bool = true
    // init : 월(2)
    var currentButtonToggle = 2
    
    // 타이틀스택 클릭시 calendar 보여주는 action
    @objc func didTapStackView (sender: UITapGestureRecognizer) {
        if currentButtonToggle == 2 {
            calendarView.setUI(type: 2)
        }else if currentButtonToggle == 3{
            calendarView.setUI(type: 3)
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
    func dataParsing(selectedData: String) {
        self.categories = [ReportData]()
        self.emotions = [ReportData]()
        self.factors = [ReportData]()
        self.satisfactions = [ReportData]()
        self.satisfactionsAvg = 0
        
        let categoryURL = APIConfig.baseURL + "/report/categories" + selectedData + "/\(UserInfo.memberId)"
        let emotionURL =  APIConfig.baseURL + "/report/emotions" + selectedData + "/\(UserInfo.memberId)"
        let factorURL = APIConfig.baseURL + "/report/factors" + selectedData + "/\(UserInfo.memberId)"
        let satisfactionURL =  APIConfig.baseURL + "/report/satisfactions" + selectedData + "/\(UserInfo.memberId)"
        let satisfactionAvgURL =  APIConfig.baseURL + "/report/satisfactions/avg" + selectedData + "/\(UserInfo.memberId)"
        
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
                                                    value: data["value"] as! Int)
                    self.categories.append(responseReport)
                }
            }
            
            if let postDict = emotionJSON as? [String: AnyObject],
               let dataDict = postDict["data"] as? [[String:Any]]
            {
                for data in dataDict{
                    let responseReport = ReportData(keyword: data["keyword"] as! String,
                                                    value: data["value"] as! Int)
                    self.emotions.append(responseReport)
                }
            }
            
            if let postDict = factorJSON as? [String: AnyObject],
               let dataDict = postDict["data"] as? [[String:Any]]
            {
                for data in dataDict{
                    let responseReport = ReportData(keyword: data["keyword"] as! String,
                                                    value: data["value"] as! Int)
                    self.factors.append(responseReport)
                }
            }
            
            if let postDict = satisfactionJSON as? [String: AnyObject],
               let dataDict = postDict["data"] as? [[String:Any]]
            {
                for data in dataDict{
                    let responseReport = ReportData(keyword: data["keyword"] as! String,
                                                    value: data["value"] as! Int)
                    self.satisfactions.append(responseReport)
                }
            }
            
            if let postDict = satisfactionAvgJSON as? [String: AnyObject],
               let data = postDict["data"] as? Int
            {
                self.satisfactionsAvg = data
            }
            
            self.setReportUI()
        }, onError: { e in
            print("error")
            print(e)
            //                self.dummyDataTextView.text = "An Error Occurred"
            self.displayError(e as NSError)
        }).disposed(by: disposeBag)
    }
    
    // scrollView
    let contentScrollView: UIScrollView = {
        let customScrollView = UIScrollView()
        customScrollView.translatesAutoresizingMaskIntoConstraints = false
        return customScrollView
    }()
    
    private let contentView: UIView = {
        let customUIView = UIView()
        customUIView.translatesAutoresizingMaskIntoConstraints = false
        return customUIView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBaseUI()
        self.calendarView.setUI(type: 2)
        self.calendarView.delegate = self
        self.contentScrollView.delegate = self
        
        var url = "/" + Global.shared.selectedYear + "/" + Global.shared.selectedMonth
        
        self.dataParsing(selectedData: url)
        
        dateStackView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapStackView(sender:)))
        dateStackView.addGestureRecognizer(tap)
    }

    // 현재 년도에서만 가능
    @objc func monthButtonAction(_ sender: UIButton){
        let url = "/" + Global.shared.currentYear + "/" + Global.shared.selectedMonth
        self.dataParsing(selectedData: url)
        
        self.calendarView.setUI(type: 2)
        self.currentButtonToggle = 2
        DispatchQueue.main.async {
            self.monthButton.isSelected = true
            self.yearButton.isSelected = false
            self.dateLabel.text = Global.shared.selectedMonth + "월"
        }
    }
    
    @objc func yearButtonAction(_ sender: UIButton){
        let url = "/" + Global.shared.selectedYear
        self.dataParsing(selectedData: url)
        
        self.calendarView.setUI(type: 3)
        self.currentButtonToggle = 3
        DispatchQueue.main.async {
            self.monthButton.isSelected = false
            self.yearButton.isSelected = true
            self.dateLabel.text = Global.shared.selectedYear + "년"
        }
    }
    
    let monthButton: CustomButton = {
        let customButton = CustomButton()
        customButton.isSelected = true
        customButton.setTitle("월간", for: .normal)
        customButton.titleLabel?.font = UIFont(name: "KimjungchulMyungjo-Bold", size: 20.0)
        customButton.setTitleColor(.systemGray, for: .normal)
        customButton.setTitleColor(.black, for: .selected)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.addTarget(self, action: #selector(monthButtonAction(_:)), for: .touchUpInside)
        return customButton
    }()
    
    let yearButton: CustomButton = {
        let customButton = CustomButton()
        customButton.setTitle("연간", for: .normal)
        customButton.setTitleColor(.systemGray, for: .normal)
        customButton.setTitleColor(.black, for: .selected)
        customButton.titleLabel?.font = UIFont(name: "KimjungchulMyungjo-Bold", size: 20.0)
        customButton.addTarget(self, action: #selector(yearButtonAction(_:)), for: .touchUpInside)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        return customButton
    }()
    
    let dateLabel: UILabel = {
        let customLabel = UILabel()
        //title 추후 수정
        customLabel.text = Global.shared.selectedMonth + "월"
        customLabel.textColor = .black
        customLabel.font = UIFont(name: "KimjungchulMyungjo-Bold", size: 20.0)
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        return customLabel
    }()
    
    /// 기본 화면 구성
    func setBaseUI(){
        buttonStackView.addArrangedSubview(monthButton)
        buttonStackView.addArrangedSubview(yearButton)
        
        self.view.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let dateButton: UIButton = {
            let customButton = UIButton()
            customButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            customButton.translatesAutoresizingMaskIntoConstraints = false
            customButton.tintColor = .black
            customButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
            customButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
            return customButton
        }()
        
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(dateButton)
        
        self.view.addSubview(dateStackView)
        NSLayoutConstraint.activate([
            dateStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            dateStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 15),
            dateStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        
        self.view.addSubview(self.contentScrollView)
        self.contentScrollView.addSubview(self.contentView)
        
        NSLayoutConstraint.activate([
            self.contentScrollView.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: 30),
            self.contentScrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.contentScrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.contentView.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor),
            self.contentView.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor),
            self.contentView.heightAnchor.constraint(equalToConstant: 1500)
        ])
        contentView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor).isActive = true
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
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
            customStackView.spacing = 12
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
            customStackView.spacing = 12
            customStackView.contentMode = .scaleToFill
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
        
        //
        for i in 0...6{
            //카테고리 타이틀
            let categoryTitleLabel: UILabel = {
                let customLabel = UILabel()
                //title 추후 수정
                customLabel.text = Tags.TagList1[i]
                customLabel.textColor = .black
                customLabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
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
                customLabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
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
            
            categoryLabelStackView.addArrangedSubview(categoryTitleLabel)
            categoryLabelStackView.addArrangedSubview(categoryValueLabel)
            categoryStackView1.addArrangedSubview(categoryLabelStackView)
        }
        
        for i in 7..<14{
            //카테고리 타이틀
            let categoryTitleLabel: UILabel = {
                let customLabel = UILabel()
                //title 추후 수정
                customLabel.text = Tags.TagList1[i]
                customLabel.textColor = .black
                customLabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
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
                customLabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
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
            categoryLabelStackView.addArrangedSubview(categoryTitleLabel)
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
            categoryStackView1.leadingAnchor.constraint(equalTo: subGraphView1.leadingAnchor, constant: 20),
            categoryStackView1.bottomAnchor.constraint(equalTo: subGraphView1.bottomAnchor, constant: -50),
            categoryStackView1.trailingAnchor.constraint(equalTo: subGraphView1.centerXAnchor, constant: -30),
            
            centerLineView.centerXAnchor.constraint(equalTo: subGraphView1.centerXAnchor),
            centerLineView.topAnchor.constraint(equalTo: subGraphView1.topAnchor, constant: 30),
            centerLineView.bottomAnchor.constraint(equalTo: subGraphView1.bottomAnchor, constant: -50),
            centerLineView.widthAnchor.constraint(equalToConstant: 1),
            
            categoryStackView2.topAnchor.constraint(equalTo: subGraphView1.topAnchor, constant: 30),
            categoryStackView2.trailingAnchor.constraint(equalTo: subGraphView1.trailingAnchor, constant: -20),
            categoryStackView2.bottomAnchor.constraint(equalTo: subGraphView1.bottomAnchor, constant: -50),
            categoryStackView2.leadingAnchor.constraint(equalTo: subGraphView1.centerXAnchor, constant: 30),
        ])
        let graphView1 = graphView.reportBaseView(title: Tags.TagTitleList[0], graph: subGraphView1)
        
        
        //2. 구매감정 report view - emotions TagList2
        let subGraphView2: UIView = {
            var customUIView = UIView()
            emotionDataList.removeAll()
            for emotion in self.emotions {
                emotionDataList.append(EmotionData(emotion: emotion.keyword,
                                                       amount: Double(emotion.value)))
            }
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
        let graphView2 = graphView.reportBaseView(title: Tags.TagTitleList[1], graph: subGraphView2)
        
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
        
        //stack in stack
        for i in 0..<5{
            let numberButton: UIButton = {
                let customButton = UIButton()
                customButton.clipsToBounds = true
                customButton.layer.cornerRadius = 3
                customButton.titleLabel?.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 16.0)
                customButton.setTitle("\(i+1)", for: .normal)
                customButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
                customButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
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
                customlabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
                customlabel.lineBreakMode = .byWordWrapping
                customlabel.translatesAutoresizingMaskIntoConstraints = false
                return customlabel
            }()
            
            //넘버 스택
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
                customlabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
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
            emotionStackView.widthAnchor.constraint(equalToConstant: 250)
        ])
        let graphView3 = graphView.reportBaseView(title: Tags.TagTitleList[2], graph: subGraphView3)
        
        
        //4. 구매만족도 report view - satisfactions TagList4
        let subGraphView4: UIView = {
            let customUIView = UIView()
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
            baseView.backgroundColor = .lightGray
            baseView.translatesAutoresizingMaskIntoConstraints = false
            return baseView
        }()
        
        let barView: UIView = {
            let baseView = UIView()
            baseView.backgroundColor = UIColor(hexCode: Global.PointColorHexCode)
            baseView.layer.cornerRadius = 10
            baseView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
            baseView.translatesAutoresizingMaskIntoConstraints = false
            return baseView
        }()
        
        let barTitleView: UILabel = {
            let customlabel = UILabel()
            customlabel.text = "\(self.satisfactionsAvg)" + "%"
            customlabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
            customlabel.lineBreakMode = .byWordWrapping
            customlabel.textAlignment = .center
            customlabel.translatesAutoresizingMaskIntoConstraints = false
            return customlabel
        }()
        
        barGraphBaseView.addSubview(barTitleView)
        barBGView.addSubview(barView)
        barGraphBaseView.addSubview(barBGView)
        
        NSLayoutConstraint.activate([
            barTitleView.centerXAnchor.constraint(equalTo: barBGView.centerXAnchor),
            barTitleView.bottomAnchor.constraint(equalTo: barBGView.topAnchor, constant: -6),
            barTitleView.widthAnchor.constraint(equalToConstant: 50),
            barTitleView.heightAnchor.constraint(equalToConstant: 22),
            
            barBGView.centerXAnchor.constraint(equalTo: barGraphBaseView.centerXAnchor),
            barBGView.centerYAnchor.constraint(equalTo: barGraphBaseView.centerYAnchor),
            barBGView.widthAnchor.constraint(equalToConstant: 34),
            barBGView.heightAnchor.constraint(equalToConstant: 180),
            
            barView.centerXAnchor.constraint(equalTo: barBGView.centerXAnchor),
            barView.bottomAnchor.constraint(equalTo: barBGView.bottomAnchor),
            barView.widthAnchor.constraint(equalToConstant: 34),
            // 그래프 비율로 계산한 유동 값
            barView.heightAnchor.constraint(equalToConstant: CGFloat(self.satisfactionsAvg * 180 / 100))
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
                customlabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
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
                customlabel.font = UIFont(name: "KimjungchulMyungjo-Regular", size: 17.0)
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
        
        subGraphView4.addSubview(barGraphBaseView)
        subGraphView4.addSubview(percentStackView)
        
        NSLayoutConstraint.activate([
            barGraphBaseView.leadingAnchor.constraint(equalTo: subGraphView4.leadingAnchor),
            barGraphBaseView.bottomAnchor.constraint(equalTo: subGraphView4.bottomAnchor),
            barGraphBaseView.topAnchor.constraint(equalTo: subGraphView4.topAnchor),
            barGraphBaseView.trailingAnchor.constraint(equalTo: subGraphView4.centerXAnchor),
            
            percentStackView.leadingAnchor.constraint(equalTo: subGraphView4.centerXAnchor, constant: 20),
            percentStackView.centerYAnchor.constraint(equalTo: subGraphView4.centerYAnchor),
            percentStackView.heightAnchor.constraint(equalToConstant: 165)
        ])
        
        let graphView4 = graphView.reportBaseView(title: Tags.TagTitleList[3], graph: subGraphView4)
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

class ReportUIView: UIView {
    private func setUI(){
        self.reportBaseView(title: "test", graph: UIView())
    }
    
    func reportBaseView(title: String, graph: UIView) -> UIView {
        // 그래프 타이틀
        let titleLabel: UILabel = {
            let customlabel = UILabel()
            customlabel.text = title
            customlabel.font = UIFont(name: "KimjungchulMyungjo-Bold", size: 20.0)
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
        reportView.addSubview(bottomLineView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: reportView.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: reportView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: reportView.trailingAnchor),
            
            //graph constraint 주기
            graph.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            graph.leadingAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.leadingAnchor),
            graph.trailingAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.trailingAnchor),
            graph.bottomAnchor.constraint(equalTo: bottomLineView.topAnchor, constant: -10),
            
            bottomLineView.heightAnchor.constraint(equalToConstant: 2),
            bottomLineView.leadingAnchor.constraint(equalTo: reportView.leadingAnchor),
            bottomLineView.trailingAnchor.constraint(equalTo: reportView.trailingAnchor),
            bottomLineView.bottomAnchor.constraint(equalTo: reportView.bottomAnchor)
        ])
        
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
                self.dateLabel.text = Global.shared.selectedYear + "년"
            }
        }
        
        self.dataParsing(selectedData: url)
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
