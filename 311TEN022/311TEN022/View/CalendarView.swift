//
//  CalendarView.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/16/23.
//

import UIKit

// Delegation Method
protocol CalendarViewDelegate: AnyObject {
    // CalendarView가 제거되기 전에 수행할 작업
    func customViewWillRemoveFromSuperview(_ customView: CalendarView)
}

// custom 캘린더 화면
class CalendarView: UIView {
    //1: normal, 2:month ver, 3:year ver
    var type = Int()
    weak var delegate: CalendarViewDelegate?
    
    // 선택시 변경될 날짜 변수
    var selectedMonth: String = Global.shared.selectedMonth
    var selectedYear: String = Global.shared.selectedYear
    
    // 날짜 변수 Array
    static let monthArr = Array(1...12).map{"\($0)" + "월"}
    static let yearArr = Array(Int(Global.shared.currentYear)!-11...Int(Global.shared.currentYear
                                                                       )!).sorted(by: <).map{"\($0)" + "년"}
    // 연도스택뷰 선택 유무
    var yearStackIsClicked: Bool = false
    
    var buttonStackView = UIStackView()
    var changeCalenderBool: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func viewTapped() {
        self.removeFromSuperview()
    }
    
    // 달력 UI Setup
    func calendarSetup(type: Int){
        let xibName = "CalendarView"
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        // init button stack : month
        if type == 1 {
            buttonStackView = makebuttonStackView(buttonTitles: CalendarView.monthArr, type: 1)
            baseView.addSubview(buttonStackView)
            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.isLayoutMarginsRelativeArrangement = true
            NSLayoutConstraint.activate(
                [
                    buttonStackView.leadingAnchor.constraint(equalTo: yearStackView.leadingAnchor),
                    buttonStackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -32),
                    buttonStackView.topAnchor.constraint(equalTo: yearStackView.bottomAnchor, constant: 10),
                    buttonStackView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -20)
                ])
        }else if type == 2{
            yearStackView.isHidden = true
            buttonStackView = makebuttonStackView(buttonTitles: CalendarView.monthArr, type: 2)
            baseView.addSubview(buttonStackView)
            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.isLayoutMarginsRelativeArrangement = true
            NSLayoutConstraint.activate(
                [
                    buttonStackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 32),
                    buttonStackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -32),
                    buttonStackView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 10),
                    buttonStackView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -20),
                ])
        }else{
            yearStackView.isHidden = true
            buttonStackView = makebuttonStackView(buttonTitles: CalendarView.yearArr, type: 3)
            baseView.addSubview(buttonStackView)
            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.isLayoutMarginsRelativeArrangement = true
            NSLayoutConstraint.activate(
                [
                    buttonStackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 32),
                    buttonStackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -32),
                    buttonStackView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 10),
                    buttonStackView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -20),
                ])
        }
        setupGesture()
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        backgroudView.addGestureRecognizer(tapGesture)
        backgroudView.isUserInteractionEnabled = true
    }
    
    // 달력 월/년 버튼
    private func makebuttonStackView(buttonTitles: [String], type: Int) -> UIStackView{
        let verticalStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            return stackView
        }()
        var monthPlus = 0
        for _ in 1...3 {
            let horizontalStackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .fill
                stackView.distribution = .fillEqually
                stackView.spacing = 10
                return stackView
            }()
            
            for _ in 1...4{
                let aButton: UIButton = {
                    let button = UIButton(type: .custom)
                    //월일 때
                    let buttonTitle = buttonTitles[monthPlus]
                    
                    //년도일 때
                    button.setTitle(buttonTitle, for: .normal)
                    button.setTitleColor(.black, for: .normal)
                    button.setBackgroundColor(.systemGray5, for: .normal)
                    
                    button.setTitleColor(UIColor(hexCode: "FCFDFC"), for: .selected)
                    button.setBackgroundColor(UIColor(hexCode: Global.PointColorHexCode)
                       , for: .selected)
                    
                    //선택 안 된 날짜 폰트
                    let font2 = UIFont(name: "KimjungchulMyungjo-Regular", size: 18.0) // 사용하려는 폰트 및 크기 선택
                    let attributes2: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font2!]
                    let attributedText2 = NSAttributedString(string: buttonTitle, attributes: attributes2)
                    button.setAttributedTitle(attributedText2, for: .normal)
                    
                    // 선택된 날짜 폰트
                    let font = UIFont(name: "KimjungchulMyungjo-Regular", size: 18.0) // 사용하려는 폰트 및 크기 선택
                    let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font!]
                    let attributedText = NSAttributedString(string: buttonTitle, attributes: attributes)
                    button.setAttributedTitle(attributedText, for: .selected)
                    
                    button.clipsToBounds = true
                    button.layer.cornerRadius = 10
                    if type == 2{
                        button.addTarget(self, action: #selector(returnButtonData2(_:)), for: .touchUpInside)
                    } else if type == 3{
                        button.addTarget(self, action: #selector(returnButtonData3(_:)), for: .touchUpInside)
                    }else{
                        button.addTarget(self, action: #selector(returnButtonData(_:)), for: .touchUpInside)
                    }
                    
                    //현재 선택된 날짜
                    if String(buttonTitle.dropLast()) == Global.shared.selectedMonth || String(buttonTitle.dropLast()) == Global.shared.selectedYear {
                        button.isSelected = true
                    }
                    return button
                }()
                horizontalStackView.addArrangedSubview(aButton)
                monthPlus += 1
            }
            verticalStackView.addArrangedSubview(horizontalStackView)
            
        }
        return verticalStackView
    }
    
    @IBOutlet weak var backgroudView: UIView!
    @IBOutlet weak var baseView: UIView!{
        didSet{
            baseView.layer.cornerRadius = 20
            baseView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)
        }
    }
    
    // homeview에서만 추가학
    // button stack 값 월 <-> 연도 변경 stack
    @IBOutlet weak var yearStackView: UIStackView!{
        didSet{
            if changeCalenderBool {
                let tap = UITapGestureRecognizer(target: self, action: #selector(didTapYearStackView(sender:)))
                yearStackView.addGestureRecognizer(tap)
            }
        }
    }
    
    @IBOutlet weak var yearTitleLabel: UILabel!{
        didSet{
            // 현재 연도
            yearTitleLabel.text = Global.shared.selectedYear + "년"
        }
    }
    
    /// calendar button stack 값 월 <-> 연도 변경 메소드
    /// - Parameter sender: year stackview
    @objc func didTapYearStackView (sender: UITapGestureRecognizer) {
        buttonStackView.removeFromSuperview()
        if yearStackIsClicked {
            yearStackIsClicked = false
            buttonStackView = makebuttonStackView(buttonTitles: CalendarView.monthArr, type: 1)
        }else{
            yearStackIsClicked = true
            buttonStackView = makebuttonStackView(buttonTitles: CalendarView.yearArr, type: 1)
        }
        
        baseView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate(
            [
                buttonStackView.leadingAnchor.constraint(equalTo: yearStackView.leadingAnchor),
                buttonStackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -32),
                buttonStackView.topAnchor.constraint(equalTo: yearStackView.bottomAnchor, constant: 10),
                buttonStackView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -20)
            ])
    }
    
    // MARK: - Calendar Button Action Method
    // 버튼 선택 action : 날짜로 data parsing, calendar view reload
    @objc func returnButtonData(_ sender: UIButton) {
        if let title = sender.titleLabel {
            let selectedDate = String(title.text!.dropLast())
            if selectedDate.count > 3 {
                Global.shared.selectedYear = selectedDate
                self.calendarSetup(type: 1)
            }else{
                Global.shared.selectedMonth = selectedDate
                delegate?.customViewWillRemoveFromSuperview(self)
                self.removeFromSuperview()
                self.calendarSetup(type: 1)
            }
        }
    }
    
    @objc func returnButtonData2(_ sender: UIButton) {
        if let title = sender.titleLabel {
            let selectedDate = String(title.text!.dropLast())
            if selectedDate.count < 3 {
                Global.shared.selectedMonth = selectedDate
            }
            self.type = 2
            delegate?.customViewWillRemoveFromSuperview(self)
            self.removeFromSuperview()
        }
    }
    
    @objc func returnButtonData3(_ sender: UIButton) {
        if let title = sender.titleLabel {
            let selectedDate = String(title.text!.dropLast())
            if selectedDate.count > 3 {
                Global.shared.selectedYear = selectedDate
            }
            self.type = 3
            delegate?.customViewWillRemoveFromSuperview(self)
            self.removeFromSuperview()
//            self.setUI(type: 3)
        }
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(backgroundImage, for: state)
    }
}
