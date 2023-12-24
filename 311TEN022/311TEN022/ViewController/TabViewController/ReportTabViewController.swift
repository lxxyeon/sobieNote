//
//  ReportTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/19/23.
//

import UIKit
import DGCharts

// TAB3. 보고서 화면
class ReportTabViewController: UIViewController, UIScrollViewDelegate {
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
    
    var currentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentScrollView.delegate = self
        setUI()
        var dayData: [String] = Tags.TagList2

    }
    //    override func viewDidLayoutSubviews()
    //    {
    //
    //        self.contentScrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 1500) // set height according you
    //    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        contentScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1500)
    //    }
    
    // 버튼 공통 메소드
    @objc func addButtonBottomLine(_ sender: UIButton){
        if sender.isSelected {
            if let sublayers = sender.layer.sublayers {
                for sublayer in sublayers {
                    if sublayer.name == "buttonBottomLine" {
                        sublayer.removeFromSuperlayer()
                        print("no click")
                        sender.isSelected = false
                    }
                }
            }
        }else{
            print("click")
            sender.layer.addBottomBorder()
            sender.isSelected = true
        }
    }
    
    func setUI() {
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
        
        let monthButton: UIButton = {
            let customButton = UIButton()
            customButton.layer.addBottomBorder()
            //            var isSelected = false
            customButton.setTitle("월간", for: .normal)
            customButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
            customButton.setTitleColor(.black, for: .normal)
            customButton.translatesAutoresizingMaskIntoConstraints = false
            customButton.addTarget(self, action: #selector(addButtonBottomLine(_:)), for: .touchUpInside)
            return customButton
        }()
        
        let yearButton: UIButton = {
            let customButton = UIButton()
            //            var isSelected = false
            customButton.setTitle("연간", for: .normal)
            customButton.setTitleColor(.black, for: .normal)
            customButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
            customButton.addTarget(self, action: #selector(addButtonBottomLine(_:)), for: .touchUpInside)
            customButton.translatesAutoresizingMaskIntoConstraints = false
            return customButton
        }()
        
        buttonStackView.addArrangedSubview(monthButton)
        buttonStackView.addArrangedSubview(yearButton)
        
        self.view.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // 월 선택 버튼
        let dateStackView: UIStackView = {
            let customStackView = UIStackView()
            customStackView.axis = .horizontal
            customStackView.alignment = .center
            customStackView.spacing = 5
            customStackView.distribution = .fill
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
        
        let dateLabel: UILabel = {
            let customLabel = UILabel()
            //title 추후 수정
            customLabel.text = Global.shared.selectedMonth
            customLabel.textColor = .black
            customLabel.font = .systemFont(ofSize: 20, weight: .semibold)
            customLabel.translatesAutoresizingMaskIntoConstraints = false
            return customLabel
        }()
        
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
            dateStackView.widthAnchor.constraint(equalToConstant: 65),
            dateStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        
        
        //
        
        //
        
        // graph view  추가
        self.view.addSubview(self.contentScrollView)
        
        self.contentScrollView.addSubview(self.contentView)
        
        NSLayoutConstraint.activate([
            self.contentScrollView.topAnchor.constraint(equalTo: dateStackView.bottomAnchor),
            self.contentScrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.contentScrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            //            self.contentScrollView.heightAnchor.constraint(equalToConstant: 2500)
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
        //        self.contentView.addSubview(self.testlabel)
        //        NSLayoutConstraint.activate([
        //            self.testlabel.leadingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.leadingAnchor),
        //            self.testlabel.heightAnchor.constraint(equalToConstant: 20),
        //            self.testlabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
        //        ])
        //
        let graphView = ReportUIView()
        //안에 들어가는 그래프
        let subGraphView1: UIView = {
            let customUIView = UIView()
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        
        let categoryStackView1: UIStackView = {
            let customStackView = UIStackView()
            customStackView.axis = .vertical
            customStackView.alignment = .center
            customStackView.distribution = .fill
            customStackView.spacing = 15
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
        
        for i in 0...6{
            let categoryTitleLabel: UILabel = {
                let customLabel = UILabel()
                //title 추후 수정
                customLabel.text = "test" + "\(i)"
                customLabel.textColor = .black
                customLabel.font = .systemFont(ofSize: 17, weight: .regular)
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                return customLabel
            }()
            
            let categoryValueLabel: UILabel = {
                let customLabel = UILabel()
                //title 추후 수정
                customLabel.text = "\(i)"
                customLabel.textColor = .black
                customLabel.font = .systemFont(ofSize: 17, weight: .regular)
                customLabel.translatesAutoresizingMaskIntoConstraints = false
                return customLabel
            }()
            
            let categorySubStackView: UIStackView = {
                let customStackView = UIStackView()
                customStackView.axis = .horizontal
                customStackView.alignment = .fill
                customStackView.distribution = .fill
                customStackView.backgroundColor = .clear
                customStackView.translatesAutoresizingMaskIntoConstraints = false
                return customStackView
            }()
            categorySubStackView.addArrangedSubview(categoryTitleLabel)
            categorySubStackView.addArrangedSubview(categoryValueLabel)
            categoryStackView1.addArrangedSubview(categorySubStackView)
        }
        
        let categoryStackView2: UIStackView = {
            let customStackView = UIStackView()
            customStackView.axis = .horizontal
            customStackView.alignment = .fill
            customStackView.distribution = .fill
            customStackView.backgroundColor = .clear
            customStackView.translatesAutoresizingMaskIntoConstraints = false
            return customStackView
        }()
 
        let centerLineView: UIView = {
            let customUIView = UIView()
            customUIView.backgroundColor = .lightGray
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        
        subGraphView1.addSubview(categoryStackView1)

//        subGraphView1.addSubview(centerLineView)
//        subGraphView1.addSubview(categoryStackView2)
        
        
        NSLayoutConstraint.activate([
            categoryStackView1.topAnchor.constraint(equalTo: subGraphView1.topAnchor),
            categoryStackView1.leadingAnchor.constraint(equalTo: subGraphView1.leadingAnchor),
            categoryStackView1.trailingAnchor.constraint(equalTo: subGraphView1.trailingAnchor),
            categoryStackView1.bottomAnchor.constraint(equalTo: subGraphView1.bottomAnchor)
            
//            centerLineView.topAnchor.constraint(equalTo: subGraphView1.topAnchor),
//            centerLineView.leadingAnchor.constraint(equalTo: graphView1.safeAreaLayoutGuide.leadingAnchor),
//            centerLineView.bottomAnchor.constraint(equalTo: graphView1.safeAreaLayoutGuide.trailingAnchor),
//            centerLineView.heightAnchor.constraint(equalToConstant: 350),
//
//            categoryStackView2.topAnchor.constraint(equalTo: subGraphView1.topAnchor),
//            categoryStackView2.leadingAnchor.constraint(equalTo: graphView3.safeAreaLayoutGuide.leadingAnchor),
//            categoryStackView2.trailingAnchor.constraint(equalTo: graphView3.safeAreaLayoutGuide.trailingAnchor),
//            categoryStackView2.bottomAnchor.constraint(equalTo: subGraphView1.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
        
        
        
        
        
        
        
        
        
        let graphView1 = graphView.reportBaseView(title: Tags.TagTitleList[0], graph: subGraphView1)
        
        let subGraphView2: UIView = {
//            let customUIView = UIView()
            let customUIView = PieChartView()
            var dayData: [String] = Tags.TagList2
            self.setPieData(pieChartView: customUIView, pieChartDataEntries: self.entryData(dataPoints : dayData, values: [45, 20, 20, 12, 9]))

            customUIView.backgroundColor = .clear
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        let graphView2 = graphView.reportBaseView(title: Tags.TagTitleList[1], graph: subGraphView2)
        
        let subGraphView3: UIView = {
            let customUIView = UIView()
            customUIView.backgroundColor = .clear
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        let graphView3 = graphView.reportBaseView(title: Tags.TagTitleList[2], graph: subGraphView3)
        
        let subGraphView4: UIView = {
            let customUIView = UIView()
            customUIView.backgroundColor = .lightGray
            customUIView.translatesAutoresizingMaskIntoConstraints = false
            return customUIView
        }()
        let graphView4 = graphView.reportBaseView(title: Tags.TagTitleList[3], graph: subGraphView4)

        //        let graphView3: UIView = {
        //            let customUIView = UIView()
        //            customUIView.backgroundColor = .blue
        //            customUIView.translatesAutoresizingMaskIntoConstraints = false
        //            return customUIView
        //        }()
        //
        //        let graphView4: UIView = {
        //            let customUIView = UIView()
        //            customUIView.backgroundColor = .purple
        //            customUIView.translatesAutoresizingMaskIntoConstraints = false
        //            return customUIView
        //        }()
        //
        contentView.addSubview(graphView1)
        contentView.addSubview(graphView2)
        contentView.addSubview(graphView3)
        contentView.addSubview(graphView4)
        //
        //
        NSLayoutConstraint.activate([
            graphView1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
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
    func entryData(dataPoints: [String], values: [Double]) -> [ChartDataEntry] {
        // entry 담을 array
        var pieDataEntries: [ChartDataEntry] = []
        // 담기
        for i in 0 ..< values.count {
            let pieDataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            pieDataEntries.append(pieDataEntry)
        }
        // 반환
        return pieDataEntries
    }
    func setPieData(pieChartView: PieChartView, pieChartDataEntries: [ChartDataEntry]) {
        // Entry들을 이용해 Data Set 만들기
        let pieChartdataSet = PieChartDataSet(entries: pieChartDataEntries)
        pieChartdataSet.sliceSpace = 1    //항목간 간격
        pieChartdataSet.colors = [UIColor(hexCode: "343C19"),
                                  UIColor(hexCode: "8D8E8A"),
                                  UIColor(hexCode: "AEAFAC"),
                                  UIColor(hexCode: "E6E6E5"),
                                  UIColor(hexCode: "F2F3F2")]
        
        // DataSet을 차트 데이터로 넣기
        let pieChartData = PieChartData(dataSet: pieChartdataSet)
        // 데이터 출력
        pieChartView.data = pieChartData
    }
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
            customlabel.font = .systemFont(ofSize: 20, weight: .semibold)
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

extension CALayer {
    func addBottomBorder() {
        let border = CALayer()
        // layer 의 두께를 3으로 설정.
        border.frame = CGRect.init(x: 0, y: frame.height - 3, width: frame.width, height: 3)
        border.cornerRadius = 1
        border.backgroundColor = UIColor(hexCode: "C7C8C6").cgColor
        
        // layer 에 name 부여.
        border.name = "buttonBottomLine"
        self.addSublayer(border)
    }
}
