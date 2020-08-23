//
//  TrainingSetViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/29.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class TrainingSetViewController: UIViewController, UITableViewDelegate {
    // キーボードの高さを監視する変数
    var keyboardHeightObservable: Observable<CGFloat>?
    // セクション
    private let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    private let userDefault = UserDefaults.standard

    let setArray = BehaviorRelay<[String]>(value: ["SET1"])
    let weightArray = BehaviorRelay<[String]>(value: [""])
    let countArray = BehaviorRelay<[String]>(value: [""])

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // userDefautsのパスを取得する
        let parentVC = parent as? TrainingSetFlontViewController
        guard let key = parentVC?.navigationItem.title else {
            return
        }
        // userDefaults読み込み
        if let trainingSetItem = userDefault.value(forKey: key) as? [[String]] {
            setArray.accept(trainingSetItem[0])
            weightArray.accept(trainingSetItem[1])
            countArray.accept(trainingSetItem[2])
        }
        // バウンスさせない
        tableView.bounces = false
        // カスタムセルの登録
        tableView.register(UINib(nibName: "TrainingSetTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainingSetTableViewCell")
        let datasource = TrainingSetViewDataSource()
        tableView.delegate = datasource
        // tableViewと値をバウンド
        Observable.combineLatest(setArray, weightArray, countArray) { TrainingSetViewDataSource.Element(setCount: $0, weight: $1, count: $2) }.bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: disposeBag)
        // 値の購読
        datasource.textArray.subscribe(onNext: { [weak self] textArray in
            guard let self = self else { return }
            self.setArray.accept(textArray[0])
            self.weightArray.accept(textArray[1])
            self.countArray.accept(textArray[2])
        }).disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        // キーボドの設定・監視
        keyboardHeightObservable = keyboardHeight()
        guard let keyboardHeightObservable = keyboardHeightObservable else {
            return
        }
        keyboardHeightObservable.subscribe(onNext: { [weak self] float in
            self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: float * 1.5, right: 0)
        }).disposed(by: disposeBag)
    }

    func keyboardHeight() -> Observable<CGFloat> {
        Observable
            .from([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        guard let notification = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return 0.0 }
                        return notification
                    },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { _ -> CGFloat in
                        0
                    }
            ])
            .merge()
    }
}
