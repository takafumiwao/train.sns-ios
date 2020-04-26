//
//  PastInputViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/17.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class PastInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private var disposeBag = DisposeBag()
    var mealAddButton: UIButton?
    var mealViewController: MealMenuViewController?
    var segmentedControl: UISegmentedControl?

    // とりあえず固定値
    var mealMenuArray = [["サラダチキン", "99.2", "100", "100", "1400"], ["酢の物", "80", "80", "80", "700"], ["カレー", "65", "55", "44", "600"], ["サラダチキンタンドリー風味", "99", "42", "2", "3999"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mealMenuArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let meal = mealMenuArray[indexPath.row]
        let mealLabel = cell.contentView.viewWithTag(1) as! UILabel
        let pLabel = cell.contentView.viewWithTag(2) as! UILabel
        let fLabel = cell.contentView.viewWithTag(3) as! UILabel
        let cLabel = cell.contentView.viewWithTag(4) as! UILabel
        mealLabel.text = meal[0]
        pLabel.text = meal[1] + "g"
        fLabel.text = meal[2] + "g"
        cLabel.text = meal[3] + "g"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeal = mealMenuArray[indexPath.row]
        // segmentedControlの挙動
        segmentedControl?.selectedSegmentIndex = 1
        mealViewController?.mealAddButton.isEnabled = true
        mealViewController?.mealAddButton.backgroundColor = .blue
        let vc = mealViewController?.children[1] as! DirectInputViewController
        vc.mealMenuTextField.text = selectedMeal[0]
        vc.pLabel.text = selectedMeal[1]
        vc.fLabel.text = selectedMeal[2]
        vc.cLabel.text = selectedMeal[3]
        vc.pSlider.value = Float(CGFloat(selectedMeal[1]))
        vc.fSlider.value = Float(CGFloat(selectedMeal[2]))
        vc.cSlider.value = Float(CGFloat(selectedMeal[3]))
        vc.kcalTextField.text = kcalNum(p: CGFloat(vc.pSlider.value), f: CGFloat(vc.fSlider.value), c: CGFloat(vc.cSlider.value))
        mealViewController?.view.bringSubviewToFront(mealViewController!.directContainerView)

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    // カロリー計算
    func kcalNum(p: CGFloat, f: CGFloat, c: CGFloat) -> String {
        let num = p * 4 + f * 9 + c * 4
        let numString = String(format: "%.0F", num)
        return numString
    }
}

extension CGFloat {
    init(_ str: String? = nil) {
        guard
            let s = str,
            let n = NumberFormatter().number(from: s) else {
            self = 0.0
            return
        }
        self = CGFloat(truncating: n)
    }
}
