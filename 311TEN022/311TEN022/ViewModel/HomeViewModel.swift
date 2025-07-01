//
//  HomeViewModel.swift
//  311TEN022
//
//  Created by leeyeon2 on 3/4/25.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class HomeViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var isEndPage: Bool = true
    
    struct Output {
        let images: Observable<[BoardImage]>
    }

}
