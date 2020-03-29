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
    var mealMenuArray = ["サラダチキン"]

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
        mealLabel.text = meal
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeal = mealMenuArray[indexPath.row]
        // segmentedControlの挙動
        segmentedControl?.selectedSegmentIndex = 1
        mealViewController?.mealAddButton.isEnabled = true
        mealViewController?.mealAddButton.backgroundColor = .blue
        let vc = mealViewController?.children[1] as! DirectInputViewController
        vc.mealMenuTextField.text = selectedMeal
        mealViewController?.view.bringSubviewToFront(mealViewController!.directContainerView)

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        tableView.sectionHeaderHeight * 20
//    }
}
