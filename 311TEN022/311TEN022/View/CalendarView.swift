//
//  CalendarView.swift
//  311TEN022
//
//  Created by leeyeon2 on 12/16/23.
//

import UIKit

class CalendarView: UIView {
    
    @IBOutlet weak var yearStackView: UIStackView!
    @IBOutlet weak var yearTitleLabel: UILabel!{
        didSet{
            yearTitleLabel.text = Global.shared.selectedYear + "년"
        }
    }
    
    let xibName = "CalendarView"
    var selectedMonth: String = Global.shared.selectedMonth
    var selectedYear: String = Global.shared.selectedYear

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        yearStackView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapYearStackView(sender:)))
        yearStackView.addGestureRecognizer(tap)
        
        let btnStackView = ButtonStackView()
        self.addSubview(btnStackView)
    }
    
    @objc func didTapYearStackView (sender: UITapGestureRecognizer) {
        // 연도 변경을 위한 선택
//        yearTitleLabel.text =
        // 선택시 월버튼 연버튼으로
        print("Stack was tapped!")
    }
}


class ButtonStackView: UIStackView {
    var buttonList = Array(1...12).map{"\($0)월"}

    
//    init() {
//        super.init(
//        self.buttonList = Array(1...12).map{"\($0)월"}
//    }
    
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func buttonStackView() -> UIStackView {
        return self.createButtonStack(stakList: self.buttonList)
    }

    func createButtonStack(stakList: [String]) -> UIStackView {
        let buttonListStackView: UIStackView = {
            let buttonListStackView = UIStackView()
            buttonListStackView.alignment = .fill
            buttonListStackView.distribution = .fillEqually
            buttonListStackView.backgroundColor = .white
            buttonListStackView.spacing = 10
            buttonListStackView.axis = .vertical
            return buttonListStackView
        }()
        
        for i in 1...3 {
            let buttonStackView: UIStackView = {
                let buttonStackView = UIStackView()
                buttonStackView.alignment = .fill
                buttonStackView.distribution = .fillEqually
                buttonStackView.backgroundColor = .white
                buttonStackView.spacing = 10
                buttonStackView.axis = .horizontal
               
                for i in 1...4 {
                    let monthButton = UIButton()
                    monthButton.setTitle("월", for: .normal)
                    buttonStackView.addArrangedSubview(monthButton)
                }

                return buttonStackView
            }()
            
            buttonListStackView.addArrangedSubview(buttonStackView)
        }

        
        return buttonListStackView
    }
}

//class ButtonView: ButtonStackView {
//    override func createButtonStack(stakList: [UIView]) -> UIStackView {
//        let buttonView = super.createButtonStack(stakList: stakList)
//        
//        buttonView.alignment = .center
//        buttonView.distribution = .fillProportionally
//        buttonView.axis = .vertical
//        return buttonView
//    }
//}
