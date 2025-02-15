//
//  HalfPieView.swift
//  311TEN022
//
//  Created by leeyeon2 on 2/15/25.
//

import SwiftUI
import Charts

struct HalfPieView: View {
    @State var progress: CGFloat = 70
    @State var displayedProgress: CGFloat = 0
    
    var body: some View {
        VStack {
            HalfCircleProgressView(progress: progress, totalSteps: 100, minValue: 0, maxValue: 100)
        }.padding()
    }
}

struct HalfCircleProgressView: View {
    var progress: CGFloat
    var totalSteps: Int
    var minValue: CGFloat
    var maxValue: CGFloat
    
    var body: some View {
        ZStack {
            HalfCircleShape()
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.gray.opacity(0.3))
                .frame(width: 200, height: 100)
            
            HalfCircleShape().trim(from: 0.0, to: normalizeProgress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(uiColor:UIColor(hexCode: "#F7CFD8")),
                                                                            Color(uiColor:UIColor(hexCode: "#F05A7E"))]),
                                                                            startPoint: .leading, endPoint: .trailing))
                .frame(width: 200, height: 100)
            VStack{
                Text("\(Int((progress/maxValue)*100))%")
            }.font(.largeTitle.bold())
        }
    }
    private var normalizeProgress: CGFloat {
        (progress - minValue) / (maxValue - minValue)
    }
    private var remainingSteps: Int {
        return max(0, totalSteps - Int(progress))
    }
}

struct HalfCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width/2, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: false)
        return path
    }
}

#Preview {
    HalfPieView()
}
