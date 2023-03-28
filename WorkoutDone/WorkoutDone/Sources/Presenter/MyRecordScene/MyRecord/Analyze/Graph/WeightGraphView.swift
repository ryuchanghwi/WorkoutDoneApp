//
//  WeightGraphView.swift
//  WorkoutDone
//
//  Created by 류창휘 on 2023/03/26.
//

import SwiftUI
import Charts

struct TestModel {
    let date : String
    let weight : Double
}
var list = [
    TestModel(date: "2023.01.01", weight: 0),
    TestModel(date: "2023.01.02", weight: 73),
    TestModel(date: "2023.01.03", weight: 74),
    TestModel(date: "2023.01.05", weight: 71),
    TestModel(date: "2023.01.06", weight: 60),
    TestModel(date: "2023.01.07", weight: 80),
    TestModel(date: "2023.01.07", weight: 80),
    TestModel(date: "2023.01.14", weight: 80),
    TestModel(date: "2023.01.15", weight: 50),
    TestModel(date: "2023.01.29", weight: 60),
    TestModel(date: "2023.02.01", weight: 70),
    TestModel(date: "2023.02.02", weight: 75),
    TestModel(date: "2023.02.03", weight: 75),
    TestModel(date: "2023.02.05", weight: 75),
    TestModel(date: "2023.02.06", weight: 75),
    TestModel(date: "2023.02.07", weight: 75),
    TestModel(date: "2023.02.08", weight: 75),
    TestModel(date: "2023.02.09", weight: 75),
    TestModel(date: "2023.02.10", weight: 75),
    TestModel(date: "2023.02.11", weight: 0),
    
]

struct WeightGraphView: View {
    ///DateToString
    func formatDate(_ date : Date) -> String {
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.day, .month], from: date)
        guard let day = dateComponents.day,
              let month = dateComponents.month else { return "-" }
        return "\(month)/\(day)"
    }
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yy/MM/dd"
        return df
    }()
    @StateObject var weightGraphViewModel = WeightGraphViewModel()
    ///TEST
    @State var testData : [TestModel] = list
    
    ///Gesture Property
    @State private var currentActiveItem : TestModel?
    ///ViewAppear 시 애니메이션 사용 위한 변수
    @State private var animate : Bool = false
    @State private var plotWidth: CGFloat = 0
    
    var body: some View {
        let max = testData.max { item1, item2 in
            return item2.weight > item1.weight
        }?.weight ?? 0
//        let max = bodyInfoGraphViewModel.bodyInfo.max { item1, item2 in
//            return item2.weight ?? 0 > item1.weight ?? 0
//        }?.weight ?? 0
        ScrollView(.horizontal) {
            Chart(testData, id: \.date) { data in
                LineMark(
                    x: .value("Month", formatDate(dateFormatter.date(from: data.date) ?? Date())),
                    y: .value("Weight", animate ? data.weight : 0)
                )
                .interpolationMethod(.cardinal)
                .foregroundStyle(Color(UIColor.color7442FF))
                PointMark(
                    x: .value("Month", formatDate(dateFormatter.date(from: data.date) ?? Date())),
                    y: .value("Weight", animate ? data.weight : 0)
                )
                ///custom point
                .annotation(position: .overlay, alignment: .center) {
                    ZStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(Color(UIColor.color7442FF))
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(UIColor.colorFFFFFF))
                    }
                    .shadow(color: Color(UIColor.color7442FF), radius: 2)
                }
//                if let currentActiveItem, currentActiveItem.date == data.date {
//                    RuleMark(x: .value("Month", formatDate(dateFormatter.date(from: data.date) ?? Date())))
//                        .lineStyle(.init(lineWidth: 1, miterLimit: 2, dash: [2], dashPhase: 5))
//                        .annotation {
//                            //FIX
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("몸무게")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                                Text("\(currentActiveItem.weight )")
//                                    .font(.title3.bold())
//                            }
//                            .padding(.horizontal, 10)
//                            .padding(.vertical, 4)
//                            .background {
//                                RoundedRectangle(cornerRadius: 6, style: .continuous)
//                                    .fill(.white.shadow(.drop(radius: 2)))
//                            }
//                        }
//                }
            }
            
//            .chartXAxis {
//                AxisMarks(preset: <#T##AxisMarkPreset#>)
//            }
            .chartYAxis {
                AxisMarks(position: .trailing)
            }
            .chartYScale(domain: 0...(max + 50))
//            .chartOverlay(content: { proxy in
//                GeometryReader { innerProxy in
//                    Rectangle()
//                        .fill(.clear).contentShape(Rectangle())
//                        .gesture(
//                            DragGesture()
//                                .onChanged({ value in
//                                    let location = value.location
//                                    if let weight : Double = proxy.value(atY: location.y) {
//                                        if let currentItem = testData.first(where: { item in
//                                            item.weight == weight
//                                        }) {
//                                            self.currentActiveItem = currentItem
//                                            print(currentActiveItem?.weight, "ss")
//                                        }
//                                    }
//                                }).onEnded({ value in
//                                    self.currentActiveItem = nil
//                                })
//                        )
//                }
//            })
            .padding()
            .frame(width: ViewConstants.dataPointWidth * CGFloat(testData.count))
//            .frame(height: 220)
        }
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(Color(UIColor.colorE6E0FF), lineWidth: 1)
        }
        .onAppear {
            print(max, "맥스값")
            for (index, _) in testData.enumerated() {
                withAnimation(.easeOut(duration: 0.8).delay(Double(index) * 0.05)) {
                    animate = true
                }
            }
        }
        .onDisappear {
            animate = false
        }
    }
    
    private struct ViewConstants {
        static let minYScale = 150
        static let maxYScale = 240
        static let dataPointWidth: CGFloat = 60
        static let chartHeight: CGFloat = 400
        static let chartWidth: CGFloat = 350
    }
}

struct WeightGraphView_Previews: PreviewProvider {
    static var previews: some View {
        WeightGraphView()
    }
}
