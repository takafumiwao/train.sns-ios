//
//  TrainingSetFlontViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/29.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class TrainingSetFlontViewController: UIViewController {
    @IBOutlet weak var trainingAddButton: UIButton!
    private var trainingSetViewController: TrainingSetViewController!
    private let disposeBag = DisposeBag()
    var indexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // トレーニング追加ボタンのフレーム設定
        trainingAddButton.frame = CGRect(x: view.frame.width - trainingAddButton.frame.width, y: view.frame.height - trainingAddButton.frame.height, width: view.frame.width / 4, height: view.frame.width / 4)

        // トレーニング追加ボタンアクション
        trainingAddButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let set = self.trainingSetViewController.setArray.value
            let weight = self.trainingSetViewController.weightArray.value
            let count = self.trainingSetViewController.countArray.value
            let trainingItem = [set, weight, count]
            if self.valueCheck(trainingItem) {
                guard let key = self.navigationItem.title else {
                    return
                }
                UserDefaults.standard.set(trainingItem, forKey: key)
                let nav = self.navigationController
                // 一つ前のViewControllerを取得する
                guard let count = nav?.viewControllers.count else {
                    return
                }
                guard let prevViewController = nav?.viewControllers[count - 2] as? TrainingMenuTableViewController else { return }

                if let array = UserDefaults.standard.value(forKey: "checkmarkArray") as? [[Bool]] {
                    var checkmarkArray = array
                    guard let indexPath = self.indexPath else {
                        return
                    }
                    guard checkmarkArray.count > indexPath.row else {
                        return
                    }
                    checkmarkArray[indexPath.section][indexPath.row] = true
                    UserDefaults.standard.set(checkmarkArray, forKey: "checkmarkArray")
                }
                prevViewController.tableView.reloadData()
                // popする
                self.navigationController?.popViewController(animated: true)
            }

        }).disposed(by: disposeBag)

        // キーボード設定
        setupKeyboard()
    }

    private func valueCheck(_ trainingItem: [[String]]) -> Bool {
        let set = trainingItem[0]
        let weight = trainingItem[1]
        let count = trainingItem[2]
        var counter = 0
        var flg = true
        while set.count > counter {
            if set[counter] == "SET1" {
                if weight[counter].isEmpty, count[counter].isEmpty {
                    flg = false
                } else {
                    flg = true
                }
            }

            counter += 1
        }
        return flg
    }

    private func setupKeyboard() {
        var flg = true
        guard let nxViewController = storyboard?.instantiateViewController(identifier: "TrainingSetViewController") as? TrainingSetViewController else { return }
        nxViewController.keyboardHeight().observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] height in
            guard let self = self else { return }
            if height == 0 {
                self.trainingAddButton.frame.origin.y = self.view.frame.height - self.trainingAddButton.frame.height
                flg = true
            } else {
                if flg {
                    self.trainingAddButton.frame.origin.y = self.trainingAddButton.frame.origin.y - height
                    flg = false
                }
            }
        }).disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext" {
            guard let destination = segue.destination as? TrainingSetViewController else {
                return
            }
            trainingSetViewController = destination
        }
    }
}
