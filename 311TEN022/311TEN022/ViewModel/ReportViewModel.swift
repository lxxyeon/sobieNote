//
//  ReportViewModel.swift
//  311TEN022
//
//  Created by leeyeon2 on 2/1/25.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

final class ReportViewModel {
    // MARK: - Properties
    private let global = Global.shared
    private let disposeBag = DisposeBag()
    //    private var dateText = String()
    
    struct Input {
        var monthButton: ControlEvent<Void>
        var yearButton: ControlEvent<Void>
//        var dateButton: ControlEvent<Void>
//        var saveReportBtn: ControlEvent<Void>
//        var shareReportBtn: ControlEvent<Void>
    }
    
    struct Output {
        let calendarIsHidden: Driver<Bool>
        let selectedButtonToggle: Driver<Bool>
        let sortedCategoryValueSet: Observable<[ReportData]>
    }
    
    func transform(input: Input) -> Output {
        
        let categoryJson = input.monthButton
            .map { _ in self.global.currentYear + "/" + self.global.selectedMonth }
            .map(parseRequest(_:))
            .compactMap { URL(string: $0) }
            .flatMap { url -> Observable<Any> in
                return json(
                    .get,
                    url,
                    headers: APIConfig.authHeaders
                )
            }
            .map({ _ in
                return [] as! [ReportData]
            })
//        let monthText = input.monthButton
//            .map {
//                return "month"
//            }
//            .asDriver(onErrorJustReturn: "")
//       
//        
//        let yearText = input.yearButton
//            .mapㄱ{
//                return "year"
//            }
//            .asDriver(onErrorJustReturn: "")
//        
//        return Output(date1: monthText, date2: yearText)
        return Output(
            calendarIsHidden: .just(false),
            selectedButtonToggle: .just(false),
            sortedCategoryValueSet: categoryJson
        )
    }
    
    func parseRequest(_ selectedData: String) -> String {
        return APIConfig.baseURL
        + "/report/categories"
        + selectedData
        + "/\(UserInfo.memberId)"
    }
}
