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

var emotionDataList: [EmotionData] = [
//    EmotionData(emotion: "고마운", amount: 1),
//    EmotionData(emotion: "불편한", amount: 3),
//    EmotionData(emotion: "행복한", amount: 2)
]

let chartColors: [Color] = [
//    Color(uiColor: UIColor(hexCode: "#343C19")),
//    Color(uiColor: UIColor(hexCode: "#747570")),
//    Color(uiColor: UIColor(hexCode: "#8D8E8A")),
//    Color(uiColor: UIColor(hexCode: "#AEAFAC")),
//    Color(uiColor: UIColor(hexCode: "#C7C8C6"))
        Color(red: 0.55, green: 0.83 , blue: 0.78),
        Color(red: 1.00, green: 1.00 , blue: 0.70),
        Color(red: 0.75, green: 0.73 , blue: 0.85),
        Color(red: 0.98, green: 0.50 , blue: 0.45),
        Color(red: 0.50, green: 0.69 , blue: 0.83)
    //    Color(red: 0.99, green: 0.71 , blue: 0.38),
    //    Color(red: 0.70, green: 0.87 , blue: 0.41),
    //    Color(red: 0.99, green: 0.80 , blue: 0.90),
    //    Color(red: 0.85, green: 0.85 , blue: 0.85),
    //    Color(red: 0.74, green: 0.50 , blue: 0.74),
    //    Color(red: 0.80, green: 0.92 , blue: 0.77),
    //    Color(red: 1.00, green: 0.93 , blue: 0.44)
]

struct PieChartView: View {
    @State private var selectedAmount: Double? = nil
    let cumulativeDatas: [(emotion: String, range: Range<Double>)]
    // 상위 5개만
    var emotionDataSorted = emotionDataList.count > 5 ? Array(emotionDataList[0...4]) : emotionDataList
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
        return emotionDataSorted[0]
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
                            .font(selectedCategory == data ? .headline : .system(size: 14))
                            .fontWeight(.regular)
                            .padding(5)
                            .background(Color.white.opacity(0.5))
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
                        VStack(spacing: 0) {
                            Text(selectedCategory?.emotion ?? "")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .frame(width: 120, height: 30)
                            Text("\((selectedCategory?.amount ?? 1)*100/emotionAmountTotal , specifier: "%.0f")%")
                                .font(.title.bold())
                                .foregroundColor((selectedCategory != nil) ? .primary : .clear)
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            .frame(height: 290)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PieChartView()
}
