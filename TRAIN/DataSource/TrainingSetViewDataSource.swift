//
//  TrainingSetViewDatasource.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/04/02.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class TrainingSetViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType, UITableViewDelegate {
    private let disposeBag = DisposeBag()
    let textArray = PublishSubject<[[String]]>()
    struct Element {
        let setCount: [String]
        let weight: [String]
        let count: [String]
    }

    private var setArray: [String] = []
    private var weightArray: [String] = []
    private var countArray: [String] = []

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        setArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        setArray[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrainingSetTableViewCell", for: indexPath) as? TrainingSetTableViewCell else {
            return UITableViewCell()
        }
        guard weightArray.count > indexPath.row, countArray.count > indexPath.row else {
            return cell
        }

        cell.weightTextField.text = weightArray[indexPath.section]
        cell.countTextField.text = countArray[indexPath.section]

        cell.weightTextField.tag = indexPath.section
        cell.countTextField.tag = indexPath.section

        guard let weightTextField = cell.weightTextField.text else {
            return cell
        }

        guard let countTextField = cell.countTextField.text else {
            return cell
        }

        if weightTextField.isEmpty, countTextField.isEmpty {
            if indexPath.section == setArray.count - 1 {
                // cell追加
                let weightObservable = cell.weightTextField.rx.text.orEmpty.asObservable()
                let countObservable = cell.countTextField.rx.text.orEmpty.asObservable()

                Observable.combineLatest(weightObservable, countObservable).filter { (t1, t2) -> Bool in

                    t1.count > 0 && t2.count > 0

                }.take(1).subscribe(onNext: { [weak self] t1, t2 in

                    guard let self = self else { return }
                    self.setArray.append("SET\(self.setArray.count + 1)")
                    self.weightArray.insert(t1, at: self.weightArray.count - 1)
                    self.countArray.insert(t2, at: self.countArray.count - 1)
                    let item = [self.setArray, self.weightArray, self.countArray]

                    self.textArray.onNext(item)

                }).disposed(by: cell.disposeBag)
            }
        } else if !weightTextField.isEmpty, !countTextField.isEmpty {
            // cell削除
            let weightObservable = cell.weightTextField.rx.text.orEmpty.asObservable()
            let countObservable = cell.countTextField.rx.text.orEmpty.asObservable()
            Observable.combineLatest(weightObservable, countObservable).filter { (t1, t2) -> Bool in
                t1.count == 0 && t2.count == 0
            }.take(1).subscribe(onNext: { [weak self] _, _ in
                guard let self = self else { return }
                let tag = cell.weightTextField.tag
                self.setArray.removeAll()
                self.weightArray.remove(at: tag)
                self.countArray.remove(at: tag)
                for i in 0 ..< self.weightArray.count {
                    self.setArray.append("SET" + String(i + 1))
                }

                let item = [self.setArray, self.weightArray, self.countArray]

                self.textArray.onNext(item)

            }).disposed(by: cell.disposeBag)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        if case let .next(element) = observedEvent {
            setArray = element.setCount
            weightArray = element.weight
            countArray = element.count
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        (tableView.frame.height - (tableView.sectionHeaderHeight * 5)) / 5
    }
}
