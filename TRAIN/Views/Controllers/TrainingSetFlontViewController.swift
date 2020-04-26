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
    var trainingSetViewController: TrainingSetViewController!
    private let disposeBag = DisposeBag()
    var indexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // トレーニング追加ボタンのフレーム設定
        trainingAddButton.frame = CGRect(x: view.frame.width - trainingAddButton.frame.width, y: view.frame.height - trainingAddButton.frame.height, width: view.frame.width / 4, height: view.frame.width / 4)

        // トレーニング追加ボタンアクション

        // MARK: textFieldの値を検知して有効無効を設定する処理が必要

        trainingAddButton.rx.tap.subscribe(onNext: { [weak self] in
            let set = self!.trainingSetViewController.setArray.value
            let weight = self!.trainingSetViewController.weightArray.value
            let count = self!.trainingSetViewController.countArray.value
            let trainingItem = [set, weight, count]
            if !(self!.valueCheck(trainingItem)) {
            } else {
                UserDefaults.standard.set(trainingItem, forKey: self!.navigationItem.title!)
                let nav = self?.navigationController
                // 一つ前のViewControllerを取得する
                let prevViewController = nav?.viewControllers[(nav?.viewControllers.count)! - 2] as! TrainingMenuTableViewController

                if let array = UserDefaults.standard.value(forKey: "checkmarkArray") as? [[Bool]] {
                    var checkmarkArray = array
                    //                checkmarkArray[self!.indexPath!.section].insert(true, at: self!.indexPath!.row)
                    checkmarkArray[self!.indexPath!.section][self!.indexPath!.row] = true
                    UserDefaults.standard.set(checkmarkArray, forKey: "checkmarkArray")
                }

                prevViewController.tableView.reloadData()

                // popする
                self?.navigationController?.popViewController(animated: true)
            }

        }).disposed(by: disposeBag)

        // キーボード設定
        setupKeyboard()
    }

    func valueCheck(_ trainingItem: [[String]]) -> Bool {
        print(trainingItem)
        let set = trainingItem[0]
        let weight = trainingItem[1]
        let count = trainingItem[2]
        var counter = 0
        var flg = true
        while set.count > counter {
            if set[counter] == "SET1" {
                if weight[counter] != "", count[counter] != "" {
                    flg = true
                } else {
                    flg = false
                }
            }

            counter += 1
        }
        return flg
    }

    func setupKeyboard() {
        var flg = true
        let nxViewController = storyboard!.instantiateViewController(identifier: "TrainingSetViewController") as! TrainingSetViewController
        nxViewController.keyboardHeight().observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] height in
            if height == 0 {
                self?.trainingAddButton.frame.origin.y = self!.view.frame.height - self!.trainingAddButton.frame.height
                flg = true
            } else {
                if flg {
                    self?.trainingAddButton.frame.origin.y = self!.trainingAddButton.frame.origin.y - height
                    flg = false
                }
            }

        }).disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext" {
            trainingSetViewController = (segue.destination as! TrainingSetViewController)
        }
    }
}
