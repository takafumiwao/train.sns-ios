//
//  DirectInputViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/17.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class DirectInputViewController: UIViewController {
    private var disposeBag = DisposeBag()
    var mealMenuViewModel: MealMenuViewModel!
    var mealAddButton: UIButton?

    @IBOutlet weak var mealMenuTextField: UITextField!
    @IBOutlet weak var kcalTextField: UITextField!
    @IBOutlet weak var pSlider: UISlider!
    @IBOutlet weak var pPlusButton: UIButton!
    @IBOutlet weak var pMinusButton: UIButton!
    @IBOutlet weak var pLabel: UILabel!
    @IBOutlet weak var fSlider: UISlider!
    @IBOutlet weak var fPlusButton: UIButton!
    @IBOutlet weak var fMinusButton: UIButton!
    @IBOutlet weak var fLabel: UILabel!
    @IBOutlet weak var cSlider: UISlider!
    @IBOutlet weak var cPlusButton: UIButton!
    @IBOutlet weak var cMinusButton: UIButton!
    @IBOutlet weak var cLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
//        var pNum: Double = NSString(string: pLabel.text!).doubleValue
//        var fNum: Double = NSString(string: fLabel.text!).doubleValue
//        var cNum: Double = NSString(string: cLabel.text!).doubleValue

//        bind()
        mealMenuViewModel = MealMenuViewModel()
        let input = MealMenuViewModelInput(mealMenuTextField: mealMenuTextField.rx.text.orEmpty.asObservable(), kcalTextField: kcalTextField.rx.text.orEmpty.asObservable(), pSlider: pSlider.rx.value.asObservable(), pPlusButton: pPlusButton.rx.tap.asObservable(), pMinusButton: pMinusButton.rx.tap.asObservable(), fSlider: fSlider.rx.value.asObservable(), fPlusButton: fPlusButton.rx.tap.asObservable(), fMinusButton: fMinusButton.rx.tap.asObservable(), cSlider: cSlider.rx.value.asObservable(), cPlusButton: cPlusButton.rx.tap.asObservable(), cMinusButton: cMinusButton.rx.tap.asObservable())
        mealMenuViewModel.setup(input: input)
        mealMenuViewModel.pValue.asDriver().drive(onNext: { value in
            self.pLabel.text = value
        }).disposed(by: disposeBag)
        mealMenuViewModel.fValue.asDriver().drive(onNext: { value in
            self.fLabel.text = value
        }).disposed(by: disposeBag)
        mealMenuViewModel.cValue.asDriver().drive(onNext: { value in
            self.cLabel.text = value
        }).disposed(by: disposeBag)
        mealMenuViewModel.pPlus.asDriver().drive(onNext: { value in
            self.pLabel.text = value
            self.pSlider.value = NSString(string: value).floatValue
        }).disposed(by: disposeBag)
        mealMenuViewModel.pMinus.asDriver().drive(onNext: { value in
            self.pLabel.text = value
            self.pSlider.value = NSString(string: value).floatValue
        }).disposed(by: disposeBag)
        mealMenuViewModel.fPlus.asDriver().drive(onNext: { value in
            self.fLabel.text = value
            self.fSlider.value = NSString(string: value).floatValue
        }).disposed(by: disposeBag)
        mealMenuViewModel.fMinus.asDriver().drive(onNext: { value in
            self.fLabel.text = value
            self.fSlider.value = NSString(string: value).floatValue
        }).disposed(by: disposeBag)
        mealMenuViewModel.cPlus.asDriver().drive(onNext: { value in
            self.cLabel.text = value
            self.cSlider.value = NSString(string: value).floatValue
        }).disposed(by: disposeBag)
        mealMenuViewModel.cMinus.asDriver().drive(onNext: { value in
            self.cLabel.text = value
            self.cSlider.value = NSString(string: value).floatValue
        }).disposed(by: disposeBag)
        mealMenuViewModel.kcal.asDriver().drive(onNext: { text in
            if text != "", self.mealMenuTextField.text != "" {
                self.mealAddButton?.isEnabled = true
                self.mealAddButton?.backgroundColor = .blue
            } else {
                self.mealAddButton?.isEnabled = false
                self.mealAddButton?.backgroundColor = .darkGray
            }
            self.kcalTextField.text = text
        }).disposed(by: disposeBag)
        mealMenuViewModel.mealMenu.asDriver().drive(onNext: { text in
            if text != "", self.kcalTextField.text != "" {
                self.mealAddButton?.isEnabled = true
                self.mealAddButton?.backgroundColor = .blue
            } else {
                self.mealAddButton?.isEnabled = false
                self.mealAddButton?.backgroundColor = .darkGray
            }
            self.mealMenuTextField.text = text
        }).disposed(by: disposeBag)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
