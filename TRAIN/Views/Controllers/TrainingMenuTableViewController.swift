//
//  TrainingMenuTableViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/27.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import UIKit

class TrainingMenuTableViewController: UITableViewController, UINavigationControllerDelegate {
    // トレーニングメニューの部位
    private let trainingPartSection = ["腕", "背中", "胸", "肩", "首", "脚", "腹"]

    // MARK: APIで取得するように修正を行う

    private let armTrainingMenu = ["アームカール", "チンアップ", "ディップス", "プッシュダウン"]
    private let bakTrainingMenu = ["プルアップ", "ダンベルプルオーバー", "ワンハンドローイング", "ラットプルダウン", "デッドリフト"]
    private let breastTrainingMenu = ["インクラインダンベルプレス", "ベンチプレス", "ダンベルフライ", "デクラインダンベルフライ"]
    private let shoulderTrainingMenu = ["サイドレイズ", "ショルダープレス", "リアレイズ"]
    private let neckTrainingMenu = ["ネックエクステンション", "ダンベルシュラッグ"]
    private let legTrainingMenu = ["スクワット", "レッグプレス", "レッグエクステンション"]
    private let bellyTrainingMenu = ["アブドミナルクランチ", "トーソロウテーション", "ケーブルクランチ", "バーティカルベンチレッグレイズ", "バーベルプッシュクランチ"]

    // チェックマークを入れる時に利用するBool値
    private var checkmarkArray = [[Bool]]()

    // トレーニングメニューを格納する配列
    private var trainingMenuArray = [[String]]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let array = UserDefaults.standard.value(forKey: "checkmarkArray") as? [[Bool]] {
            checkmarkArray = array
        } else {
            checkmarkArray = [[false, false, false, false], [false, false, false, false, false], [false, false, false, false], [false, false, false], [false, false], [false, false, false], [false, false, false, false, false]]
            UserDefaults.standard.set(checkmarkArray, forKey: "checkmarkArray")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        // バウンスさせない
        tableView.bounces = false

        // トレーニングメニューを格納する
        for _ in 0 ... trainingPartSection.count {
            trainingMenuArray.append([])
        }
        trainingMenuArray[0] = armTrainingMenu
        trainingMenuArray[1] = bakTrainingMenu
        trainingMenuArray[2] = breastTrainingMenu
        trainingMenuArray[3] = shoulderTrainingMenu
        trainingMenuArray[4] = neckTrainingMenu
        trainingMenuArray[5] = legTrainingMenu
        trainingMenuArray[6] = bellyTrainingMenu
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        trainingPartSection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trainingMenuArray[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        trainingPartSection[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainingMenuCell", for: indexPath)

        guard checkmarkArray.count > indexPath.row else {
            return cell
        }
        // トレーニングを追加したcellにチェックマークを入れる
        if checkmarkArray[indexPath.section][indexPath.row] == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = trainingMenuArray[indexPath.section][indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "TrainingSetViewController", bundle: nil)
        // 次画面にIndexPathを渡して遷移する
        guard let nxViewController = storyBoard.instantiateViewController(withIdentifier: "TrainingSetFlontViewController") as? TrainingSetFlontViewController
        else { return }
        nxViewController.indexPath = indexPath
        nxViewController.navigationItem.title = trainingMenuArray[indexPath.section][indexPath.row]
        navigationController?.pushViewController(nxViewController, animated: true)
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let apVC = viewController as? PostArticleViewController else { return }
        apVC.settingParts()
    }
}
