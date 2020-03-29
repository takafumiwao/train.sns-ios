//
//  TrainingSetTableViewModel.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/29.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift

class TrainingSetTableViewModel {
    let disposeBag = DisposeBag()
    // 重量
    let weight = BehaviorRelay<String>(value: "")
    // 回数
    let count = BehaviorRelay<String>(value: "")
    // cellを増やすかどうかの判断値
    let cellAdd: Observable<Bool>

    init() {
        cellAdd = Observable.combineLatest(weight.asObservable(), count.asObservable()) { weight, count in
            var result = false
            if weight != "", count != "" {
                result = true
            }
            return result
        }
    }
}
