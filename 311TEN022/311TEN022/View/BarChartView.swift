//
//  BarChartView.swift
//  311TEN022
//
//  Created by leeyeon2 on 4/20/24.
//

import SwiftUI
import Charts

struct SatisfactionData: Identifiable, Equatable {
    var satisfaction: String
    var amount: Double
    var id = UUID()
}


let SatisfactionDataList: [SatisfactionData] = [
    SatisfactionData(satisfaction: "20%",
                     amount: 2),
    SatisfactionData(satisfaction: "40%",
                     amount: 1),
    SatisfactionData(satisfaction: "60%",
                     amount: 3),
    SatisfactionData(satisfaction: "80%",
                     amount: 2),
    SatisfactionData(satisfaction: "100%",
                     amount: 3)
]


let barChartColors: [Color] = [
    Color(uiColor: #colorLiteral(red: 0.5612587333, green: 0.8623973727, blue: 0.8302478194, alpha: 1)),
    Color(uiColor: #colorLiteral(red: 0.5995829701, green: 0.9314802885, blue: 1, alpha: 1)),
    Color(uiColor: #colorLiteral(red: 0.6791455411, green: 0.6645288462, blue: 0.9568627451, alpha: 1)),
    Color(uiColor: UIColor(hexCode: "#b1e7e1")),
    Color(uiColor: UIColor(hexCode: "#c2eaff")),
    Color(uiColor: UIColor(hexCode: "#e1e0f4")),
    Color(uiColor: UIColor(hexCode: "#f0dbef")),
    Color(uiColor: UIColor(hexCode: "#feebd6"))
]

let satisfactionList = ["20","40","60","80","100"]

struct BarChartView: View {
    
    init(){
        
    }
    @State private var selectedValue: String?
    //    @State private var walk = SatisfactionDataList
    @State private var selectedPoint: SatisfactionData? = nil
    var body: some View {
        VStack {
            Chart {
                ForEach(SatisfactionDataList) { w in
                    LineMark(x: .value("Day",  w.satisfaction),
                             y: .value("Mins", w.amount))
                    .lineStyle(.init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    // Add interaction for points
                    
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("X Axis", w.satisfaction),
                        y: .value("Y Axis", w.amount)
                    )
                    .foregroundStyle(barChartColors[0])
                    .symbolSize(50)
                    
                    //이거 왜 에러;;
                    //                    .onTapGesture {
                    //                        selectedPoint = w
                    //                    }
                    
                }
                .foregroundStyle(Gradient(colors: [barChartColors[0],
                                                   barChartColors[1],
                                                   barChartColors[2]]))
//                .foregroundStyle(Gradient(colors: [Color(uiColor:UIColor(hexCode:Global.PointColorHexCode)),
//                                                   barChartColors[1],
//                                                   Color(uiColor:UIColor(hexCode: "#E6F4F1"))]))
                //                .interpolationMethod(.cardinal)
                if let selected = selectedPoint {
                    PointMark(
                        x: .value("X Axis", selected.satisfaction),
                        y: .value("Y Axis", selected.amount)
                    )
                    .foregroundStyle(.red)
                    .symbolSize(100)
                    .annotation(position: .top) {
                        Text("Value: \(Int(selected.amount))")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                }
                
                if let maxPoint = SatisfactionDataList.max(by: { $0.amount < $1.amount }) {
                    PointMark(
                        x: .value("X Axis", maxPoint.satisfaction),
                        y: .value("Y Axis", maxPoint.amount)
                    )
                    .foregroundStyle(barChartColors[0])
                    .symbolSize(100)
                    .annotation(position: .top) {
                        Text("Max: \(Int(maxPoint.amount))")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(barChartColors[0]).opacity(0.8)
                            .cornerRadius(5)
                    }
                }
                
            }
            
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(stroke: StrokeStyle(lineWidth: 0))
            }.chartOverlay { (chartProxy: ChartProxy) in
                Color.clear
                    .onContinuousHover { hoverPhase in
                        switch hoverPhase {
                        case .active(let hoverLocation):
                            selectedValue = chartProxy.value(
                                atX: hoverLocation.x, as: String.self
                            )
                        case .ended:
                            selectedValue = nil
                        }
                    }
            }
            //
            //                .chartYScale(domain: [0, 100])
            .onTapGesture {
                print("tap")
                selectedPoint = nil // Deselect the point on empty tap
            }
        }.padding()
            .onTapGesture {
                print("tap")
                selectedPoint = nil // Deselect the point on empty tap
            }
    }
}

#Preview {
    BarChartView()
}
