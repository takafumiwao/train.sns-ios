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
    var setItemEvent = BehaviorRelay<[String]>(value: [])
    var items: Observable<[String]> {
        setItemEvent.asObservable()
    }

    var setitems = ["SET1"]
    var flg = true

    init() {
        setItemEvent.accept(setitems)
    }

    var rx_items: AnyObserver<Bool> {
        AnyObserver<Bool>(eventHandler: { _ in
            if self.flg {
                self.addItem(item: "SET2")
                print("addItem")
            }
            self.flg = false
        })
    }

    func addItem(item: String) {
        setitems.append(item)
        print(setitems.count)
        flg = false
    }
}
