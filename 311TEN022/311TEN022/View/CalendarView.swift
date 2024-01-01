//
//  CalendarView.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/16/23.
//

import UIKit

// Delegation Method
protocol CalendarViewDelegate: AnyObject {
    func customViewWillRemoveFromSuperview(_ customView: CalendarView)
}

// custom 캘린더 화면
class CalendarView: UIView {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUI()
    }

    @objc private func viewTapped() {
        self.removeFromSuperview()
    }
    
    private func setUI(){
        let xibName = "CalendarView"
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        // init button stack : month
        buttonStackView = makebuttonStackView(buttonTitles: CalendarView.monthArr)
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
        setupGesture()
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        backgroudView.addGestureRecognizer(tapGesture)
        backgroudView.isUserInteractionEnabled = true
    }
    
    private func makebuttonStackView(buttonTitles: [String]) -> UIStackView{
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
                    
                    button.setBackgroundColor(.systemGray4, for: .normal)
                    button.setBackgroundColor(.systemGray2, for: .selected)
                    
                    let font = UIFont(name: "Helvetica-Bold", size: 18.0) // 사용하려는 폰트 및 크기 선택
                    let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font!]
                    let attributedText = NSAttributedString(string: buttonTitle, attributes: attributes)
                    button.setAttributedTitle(attributedText, for: .selected)
                    
                    button.clipsToBounds = true
                    button.layer.cornerRadius = 10
                    button.addTarget(self, action: #selector(returnButtonData(_:)), for: .touchUpInside)
                    
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
    
    // button stack 값 월 <-> 연도 변경 stack
    @IBOutlet weak var yearStackView: UIStackView!{
        didSet{
            //            yearStackView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapYearStackView(sender:)))
            yearStackView.addGestureRecognizer(tap)
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
            buttonStackView = makebuttonStackView(buttonTitles: CalendarView.monthArr)
        }else{
            yearStackIsClicked = true
            buttonStackView = makebuttonStackView(buttonTitles: CalendarView.yearArr)
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
            if selectedDate.count > 2 {
                Global.shared.selectedYear = selectedDate
                self.setUI()
            }else{
                Global.shared.selectedMonth = selectedDate
                delegate?.customViewWillRemoveFromSuperview(self)
                self.removeFromSuperview()
                self.setUI()
            }
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
