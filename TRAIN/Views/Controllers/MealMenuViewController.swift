//
//  MealMenuViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/29.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxSwift
import UIKit

class MealMenuViewController: UIViewController, UINavigationControllerDelegate {
    private let disposeBag = DisposeBag()
    var mealMenuViewModel: MealMenuViewModel!
    var topSafeAreaHeight: CGFloat = 0
    var bottomSafeAreaHeight: CGFloat = 0
    var switchView: UIView?

    @IBOutlet weak var seg_: UISegmentedControl!
    @IBOutlet weak var pastContainerView: UIView!
    @IBOutlet weak var directContainerView: UIView!
    @IBOutlet weak var mealAddButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let nvVc = navigationController else {
            return
        }
        nvVc.delegate = self
        mealAddButton.isEnabled = false
        mealAddButton.backgroundColor = .darkGray
        guard let diVC = children[1] as? DirectInputViewController else { return }
        guard let piVC = children[0] as? PastInputViewController else { return }
        diVC.mealAddButton = mealAddButton
        piVC.mealAddButton = mealAddButton
        piVC.segmentedControl = seg_
        piVC.mealViewController = self
        // segmentedControlの挙動
        seg_.rx.selectedSegmentIndex.asControlProperty().subscribe(onNext: { index in
            switch index {
            case 0: print("0")
                self.view.bringSubviewToFront(self.pastContainerView)
            case 1: print("1")
                self.view.bringSubviewToFront(self.directContainerView)
            default: break
            }
        }).disposed(by: disposeBag)
        // 追加するボタン
        mealAddButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            guard let vc = self.children[1] as? DirectInputViewController else { return }
            guard let m = vc.mealMenuTextField.text,
                let k = vc.kcalTextField.text,
                let p = vc.pLabel.text,
                let f = vc.fLabel.text,
                let c = vc.cLabel.text else { return }
            let mealArray = [m, k, p, f, c]
            // 値を保存
            if let mealMenu = UserDefaults.standard.value(forKey: "Meal") {
                // 値が存在する場合
                guard let mealMenu = mealMenu as? [[String]] else { return }
                var array = mealMenu
                array.append(mealArray)
                UserDefaults.standard.set(array, forKey: "Meal")
            } else {
                // 値が存在しない場合
                UserDefaults.standard.set([mealArray], forKey: "Meal")
            }
            // popする
            self.navigationController?.popViewController(animated: true)

        }).disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = initViewLayout
    }

    private lazy var initViewLayout: Void = {
        // viewDidLayoutSubviewsではSafeAreaの取得ができている
        topSafeAreaHeight = self.view.safeAreaInsets.top
        bottomSafeAreaHeight = self.view.safeAreaInsets.bottom
        seg_.frame = CGRect(x: 0, y: topSafeAreaHeight, width: view.frame.width, height: self.view.frame.height / 12)
        mealAddButton.layer.cornerRadius = 10.0
        pastContainerView.frame = CGRect(x: 0, y: seg_.frame.origin.y + seg_.frame.height, width: view.frame.width, height: view.frame.height - seg_.frame.height - (mealAddButton.frame.height * 2) - topSafeAreaHeight - bottomSafeAreaHeight)
        directContainerView.frame = CGRect(x: 0, y: seg_.frame.origin.y + seg_.frame.height, width: view.frame.width, height: view.frame.height - seg_.frame.height - (mealAddButton.frame.height * 2) - topSafeAreaHeight - bottomSafeAreaHeight)
    }()

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let apVC = viewController as? PostArticleViewController else { return }
        apVC.settingParts()
    }
}
