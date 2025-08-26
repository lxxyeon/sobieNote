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

    struct Input {
        var monthButton: ControlEvent<Void>
        var yearButton: ControlEvent<Void>
        var didTapMonthButton: ControlEvent<Void>
        var didTapYearButton: ControlEvent<Void>
        var didChangeCalendar: Observable<Int>
        var didTapDateStackView: Observable<Void>
    }
    
    struct Output {
        let calendarIsHidden: Driver<Bool>
        let selectedButtonToggle: Driver<Bool>
        let sortedCategoryValueSet: Observable<[ReportData]>
        
        var currentYear: Driver<String>
        var currentMonth: Driver<String>
        var categories: Driver<[ReportData]>
        var currentCalendarIndex: Driver<Int>
        var isHiddenCalendar: Driver<Bool>
    }
    
    private let disposeBag = DisposeBag()
    private let currentYearSubject: PublishRelay<String>
    private let currentMonthSubject: BehaviorRelay<String>
    private let categoriesSubject: BehaviorRelay<[ReportData]>
    private let currentCalendarIndexSubject: BehaviorRelay<Int>
    private let isHiddenCalendarSubject: BehaviorRelay<Bool>
    
    init() {
        currentYearSubject = PublishRelay<String>()
        currentMonthSubject = BehaviorRelay<String>(value: Global.shared.currentMonth)
        categoriesSubject = BehaviorRelay<[ReportData]>(value: Tags.TagList1.map { ReportData(keyword: $0, value: 0)} )
        currentCalendarIndexSubject = BehaviorRelay<Int>(value: 2)
        isHiddenCalendarSubject = BehaviorRelay<Bool>(value: true)
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
        input.didTapYearButton
            .map { return Global.shared.currentYear }
            .subscribe(onNext: { [weak self] year in
                guard let self = self else { return }
                
                let selectedData = "/" + year
                let categories = self.dataParsing(selectedData: selectedData)
                self.categoriesSubject.accept(categories)
                self.currentYearSubject.accept(year)
                self.currentCalendarIndexSubject.accept(3)
            })
            .disposed(by: disposeBag)
        
        input.didTapMonthButton
            .map { return (Global.shared.currentYear!, Global.shared.currentMonth!) }
            .subscribe(onNext: { [weak self] (year, month) in
                guard let self = self else { return }
                
                let selectedData = "/" + year + "/" + month
                let categories = self.dataParsing(selectedData: selectedData)
                self.categoriesSubject.accept(categories)
                self.currentMonthSubject.accept(month)
                self.currentCalendarIndexSubject.accept(2)
            })
            .disposed(by: disposeBag)
        
        input.didChangeCalendar
            .subscribe { [weak self] calendarIndex in
                guard let self = self else { return }
                
                if calendarIndex == 2 {
                    let month = Global.shared.currentMonth!
                    let selectedData = "/" + Global.shared.selectedMonth
                    let categories = self.dataParsing(selectedData: selectedData)
                    
                    self.categoriesSubject.accept(categories)
                    self.currentMonthSubject.accept(month)
                } else {
                    let year = Global.shared.currentYear!
                    let month = Global.shared.currentMonth!
                    let selectedData = "/" + year + "/" + month
                    let categories = self.dataParsing(selectedData: selectedData)
                    
                    self.categoriesSubject.accept(categories)
                    self.currentYearSubject.accept(year)
                }
            }
            .disposed(by: disposeBag)
        
        input.didTapDateStackView
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                
                self.isHiddenCalendarSubject.accept(!self.isHiddenCalendarSubject.value)
            }
            .disposed(by: disposeBag)
        
        return Output(
            calendarIsHidden: .just(false),
            selectedButtonToggle: .just(false),
            sortedCategoryValueSet: categoryJson,
            currentYear: currentYearSubject.asDriver(onErrorDriveWith: .empty()),
            currentMonth: currentMonthSubject.asDriver(onErrorDriveWith: .empty()),
            categories: categoriesSubject.asDriver(onErrorDriveWith: .empty()),
            currentCalendarIndex: currentCalendarIndexSubject.asDriver(onErrorDriveWith: .empty()),
            isHiddenCalendar: isHiddenCalendarSubject.asDriver(onErrorDriveWith: .empty())
        )
    }
    
    // MARK: Private Methods
    private func dataParsing(selectedData: String) -> [ReportData] {
        return Tags.TagList1
            .map {
                ReportData(keyword: $0, value: Int.random(in: 0...100))
            }
            .sorted(by: { $0.value > $1.value })
    }
    
    private func parseRequest(_ selectedData: String) -> String {
        return APIConfig.baseURL
        + "/report/categories"
        + selectedData
        + "/\(UserInfo.memberId)"
    }
}
