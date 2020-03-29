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
    private let disposeBag = DisposeBag()
    var indexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // トレーニング追加ボタンのフレーム設定
        trainingAddButton.frame = CGRect(x: view.frame.width - trainingAddButton.frame.width, y: view.frame.height - trainingAddButton.frame.height, width: view.frame.width / 4, height: view.frame.width / 4)

        // トレーニング追加ボタンアクション

        // MARK: textFieldの値を検知して有効無効を設定する処理が必要

        trainingAddButton.rx.tap.subscribe(onNext: { [weak self] in
            let nav = self?.navigationController
            // 一つ前のViewControllerを取得する
            let prevViewController = nav?.viewControllers[(nav?.viewControllers.count)! - 2] as! TrainingMenuTableViewController
            prevViewController.checkmarkArray[self!.indexPath!.section].insert(true, at: self!.indexPath!.row)
            prevViewController.tableView.reloadData()
            // popする
            self?.navigationController?.popViewController(animated: true)

        }).disposed(by: disposeBag)

        // キーボード設定
        setupKeyboard()
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
}
