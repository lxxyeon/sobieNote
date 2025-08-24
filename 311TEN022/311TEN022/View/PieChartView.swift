//
//  PieChartView.swift
//  311TEN022
//
//  Created by leeyeon2 on 2/23/24.
//

import SwiftUI
import Charts

struct EmotionData: Identifiable, Equatable {
    var emotion: String
    var amount: Double
    var id = UUID()
}

var emotionDataList: [EmotionData] = []

let chartColors: [Color] = [
    Color(uiColor: UIColor(hexCode: "#b1e7e1")),
    Color(uiColor: UIColor(hexCode: "#c2eaff")),
    Color(uiColor: UIColor(hexCode: "#e1e0f4")),
    Color(uiColor: UIColor(hexCode: "#f0dbef")),
    Color(uiColor: UIColor(hexCode: "#feebd6")),
    Color(uiColor: UIColor(hexCode: "#EBE8DB"))
]

struct PieChartView: View {
    @State private var selectedAmount: Double? = nil
    
    let cumulativeDatas: [(emotion: String, range: Range<Double>)]
    
    // 상위 6개만 출력
    var emotionDataSorted = emotionDataList.count > 6 ? Array(emotionDataList[0...5]) : emotionDataList
    let emotionAmountTotal = emotionDataList.map{ $0.amount }.reduce(0, +)
    
    init() {
        emotionDataSorted.sort {
            $0.amount > $1.amount
        }
        var cumulative = 0.0
        
        self.cumulativeDatas = emotionDataSorted.map {
            let newCumulative = cumulative + Double($0.amount)
            let result = (emotion: $0.emotion, range: cumulative ..< newCumulative)
            cumulative = newCumulative
            return result
        }
    }
    
    var selectedCategory: EmotionData? {
        if let selectedAmount,
           let selectedIndex = cumulativeDatas
            .firstIndex(where: { $0.range.contains(selectedAmount) }) {
            return emotionDataSorted[selectedIndex] // 범위에 포함하는 데이터 리턴
        }
        // 데이터 없는 경우
        return nil
    }

    var body: some View {
        VStack {
            GroupBox() {
                Chart(emotionDataSorted) { data in
                    let amountStr = "\(data.emotion)"
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: .ratio(selectedCategory == data ? 0.5 : 0.5),
                        outerRadius: .ratio(selectedCategory == data ? 1.0 : 0.9),
                        angularInset: 3.0
                    )
                    .cornerRadius(6.0)
                    .foregroundStyle(by: .value("emotion", data.emotion))
                    .opacity(selectedCategory == data ? 1.0 : 0.9)
                    .annotation(position: .overlay) {
                        Text(amountStr)
                            .font(selectedCategory == data ? .headline : .custom("KimjungchulMyungjo-Regular", size: 13.0))
                            .foregroundColor(Color(uiColor: UIColor(hexCode: "#575757")))
                            .fontWeight(.regular)
                            .padding(5)
                            .background(Color.white.opacity(0.4))
                            .opacity(selectedCategory == data ? 0 : 1)
                    }
                }
                .animation(.easeIn, value: emotionDataSorted)
                .chartForegroundStyleScale(
                    domain: emotionDataSorted.map  { $0.emotion },
                    range: chartColors
                )
                .chartLegend(.hidden)
                .chartAngleSelection(value: $selectedAmount)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotFrame!]
                        let amountValue: Double = (selectedCategory?.amount ?? 1)*100/emotionAmountTotal
                        VStack(spacing: 0) {
                            // 데이터 없는 경우
                            Text(selectedCategory?.emotion ?? emotionDataSorted[0].emotion)
                                .multilineTextAlignment(.center)
//                                .font(.system(size: 26, weight: .semibold, design: .default))
                                .font(.custom("KimjungchulMyungjo-Bold", size: 26.0))
                                .foregroundColor(Color.black)
                                .foregroundStyle(.secondary)
                                .frame(width: 120, height: 30)
                            Text("\(amountValue.isNaN ? 0 : amountValue, specifier: "%.0f")%")
//                                .font(.system(size: 21, weight: .medium, design: .default))
                                .font(.custom("KimjungchulMyungjo-Regular", size: 21.0))
                                .foregroundColor((selectedCategory != nil) ? .primary : .primary)
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            .frame(height: 280)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PieChartView()
}
