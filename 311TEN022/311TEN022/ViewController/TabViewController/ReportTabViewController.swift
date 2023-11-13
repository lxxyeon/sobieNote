//
//  ReportTabViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/6/23.
//

import UIKit
import DGCharts

class ReportTabViewController: UIViewController {

    @IBAction func hiddenAction(_ sender: Any) {
        if hiddenView.isHidden == false{
            hiddenView.isHidden = true
        }else{
            hiddenView.isHidden = false
        }
    }
    @IBOutlet weak var hiddenView: UIView!{
        didSet{
            hiddenView.isHidden = true

        }
    }
    @IBOutlet weak var stackView1: UIView!
    @IBOutlet weak var stackView2: UIView!
    @IBOutlet weak var yearLineView: UIView!{
        didSet{
            yearLineView.isHidden = true
        }
    }
    //1 section
    @IBOutlet weak var s1: UILabel!
    @IBOutlet weak var s2: UILabel!
    @IBOutlet weak var s3: UILabel!
    @IBOutlet weak var s4: UILabel!
    @IBOutlet weak var s5: UILabel!
    @IBOutlet weak var s6: UILabel!
    @IBOutlet weak var s7: UILabel!
    @IBOutlet weak var s8: UILabel!
    @IBOutlet weak var s9: UILabel!
    @IBOutlet weak var s10: UILabel!
    @IBOutlet weak var s11: UILabel!
    @IBOutlet weak var s12: UILabel!
    @IBOutlet weak var s13: UILabel!
    @IBOutlet weak var s14: UILabel!
    
    //3 section
    @IBOutlet weak var score1title: UILabel!
    @IBOutlet weak var score2title: UILabel!
    @IBOutlet weak var score3title: UILabel!
    @IBOutlet weak var score4title: UILabel!
    @IBOutlet weak var score5title: UILabel!
    
    
    @IBOutlet weak var score1value: UILabel!
    @IBOutlet weak var score2value: UILabel!
    @IBOutlet weak var score3value: UILabel!
    @IBOutlet weak var score4value: UILabel!
    @IBOutlet weak var score5value: UILabel!
    
    let tag1 = Tags.TagList1
//    ["식품","패션","디지털","미용","반려동물","스포츠","인테리어","도서","자동차","가전","건강","생활용품","취미","여행"]
    func setLabelStack()  {
        let stack1 = makeLabelStacks(tags: tag1)
        //        stack1.axis = .vertical // or .horizontal
        //        stack1.spacing = 16
        //        NSLayoutConstraint.activate([
        //            stack1.widthAnchor.constraint(equalToConstant: 150),
        //            stack1.heightAnchor.constraint(equalToConstant: 250)
        //        ])
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        stackView1.addSubview(stack1)
    }
    
    func makeLabelStacks(tags: [String]) -> UIStackView {
        let labelStacks = UIStackView()
        labelStacks.axis = .vertical
        labelStacks.spacing = 50
        //작은 stack
        for i in 0..<2 {
            let babbyStack = makeLabelStack(titleStr: tags[i], valueStr: tags[i])
            labelStacks.addSubview(babbyStack)
        }
        
        NSLayoutConstraint.activate([
            labelStacks.widthAnchor.constraint(equalToConstant: 150),
            labelStacks.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        labelStacks.translatesAutoresizingMaskIntoConstraints = false
        return labelStacks
    }
    
    func makeLabelStack(titleStr: String, valueStr: String) -> UIStackView {
        let labelStack = UIStackView()
        labelStack.axis = .horizontal // or .horizontal
        //        stackView.alignment = .center
        labelStack.distribution = .fill
//        labelStack.spacing = 50 // Adjust spacing as needed
        
        // Create and add subviews to the stack view
        let title = UILabel()
        title.text = titleStr
        labelStack.addArrangedSubview(title)
        
        let value = UILabel()
        value.text = valueStr
        NSLayoutConstraint.activate([
            labelStack.widthAnchor.constraint(equalToConstant: 130),
//            labelStacks.heightAnchor.constraint(equalToConstant: 500)
        ])
        labelStack.addArrangedSubview(value)
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        return labelStack
    }
    
    override func viewDidLoad() {
//        setLabelStack()
        super.viewDidLoad()
        
        // 기본 출력 텍스트
        self.pieChart.noDataText = "출력 데이터가 없습니다."
        // 기본 출력 텍스트 폰트
        self.pieChart.noDataFont = .systemFont(ofSize: 20)
        // 기본 출력 텍스트 색상
        self.pieChart.noDataTextColor = .lightGray
        // Chart 뒷 배경 색상
        //        self.pieChart.backgroundColor = UIColor(hexCode: "343C19")
        var dayData: [String] = Tags.TagList2
        self.setPieData(pieChartView: self.pieChart, pieChartDataEntries: self.entryData(dataPoints : dayData, values: self.priceData))
    }
    
    
    @IBOutlet weak var pieChart: PieChartView!
    
    
    
  
    var priceData: [Double]! = [45, 20, 20, 12, 9]
    
    // 데이터 적용하기
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
    
    // entry 만들기
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
    
    @IBOutlet weak var barGraphView: UIView!{
        didSet{
            //            barGraphView.frame.height = 70
        }
    }
    
}
