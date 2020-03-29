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

class TrainingSetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // キーボードの高さを監視する変数
    var keyboardHeightObservable: Observable<CGFloat>?
    // セクション
    private var trainingSetSection = ["SET1", "SET2", "SET3", "SET4", "SET5", "SET6", "SET7", "SET8", "SET9", "SET10"]
    private var disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // キーボドの設定・監視
        keyboardHeightObservable = keyboardHeight()
        keyboardHeightObservable?.subscribe(onNext: { [weak self] float in
            self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: float * 1.5, right: 0)
        }).disposed(by: disposeBag)
        // バウンスさせない
        tableView.bounces = false
        // カスタムセルの登録
        tableView.register(UINib(nibName: "TrainingSetTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainingSetTableViewCell")
    }

    func keyboardHeight() -> Observable<CGFloat> {
        Observable
            .from([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                    },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { _ -> CGFloat in
                        0
                    }
            ])
            .merge()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        trainingSetSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        trainingSetSection[section]
    }

    // MARK: ここの値の監視がわからない

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainingSetTableViewCell", for: indexPath) as! TrainingSetTableViewCell
        let cellViewModel = cell.viewModel
        cell.weightTextField.rx.text.orEmpty.bind(to: cellViewModel.weight).disposed(by: cell.disposeBag)
        cell.countTextField.rx.text.orEmpty.bind(to: cellViewModel.count).disposed(by: cell.disposeBag)
        cell.viewModel.cellAdd.subscribe(onNext: { _ in }).disposed(by: cell.disposeBag)
        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.sectionHeaderHeight * 4.0
    }
}
