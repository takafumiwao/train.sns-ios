//
//  MealMenuViewModel.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/28.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift

struct MealMenuViewModelInput {
    // 食事メニューを記載するテキストフィールド
    let mealMenuTextField: Observable<String>
    // カロリーを記載するテキストフィールド
    let kcalTextField: Observable<String>
    // タンパク質スライダー
    let pSlider: Observable<Float>
    // タンパク質増やすボタン
    let pPlusButton: Observable<Void>
    // タンパク質減らすボタン
    let pMinusButton: Observable<Void>
    // 脂質スライダー
    let fSlider: Observable<Float>
    // 脂質増やすボタン
    let fPlusButton: Observable<Void>
    // 脂質減らすボタン
    let fMinusButton: Observable<Void>
    // 炭水化物スライダー
    let cSlider: Observable<Float>
    // 炭水化物増やすボタン
    let cPlusButton: Observable<Void>
    // 炭水化物減らすボタン
    let cMinusButton: Observable<Void>
}

protocol MealMenuViewModelOutput {
    // 食事メニュー名
    var mealMenu: Driver<String> { get }
    // カロリー
    var kcal: Driver<String> { get }
    // p値
    var pValue: Driver<String> { get }
    var pPlus: Driver<String> { get }
    var pMinus: Driver<String> { get }
    // f値
    var fValue: Driver<String> { get }
    var fPlus: Driver<String> { get }
    var fMinus: Driver<String> { get }
    // c値
    var cValue: Driver<String> { get }
    var cPlus: Driver<String> { get }
    var cMinus: Driver<String> { get }
}

protocol MealMenuViewModelType {
    var outputs: MealMenuViewModelOutput? { get }
    func setup(input: MealMenuViewModelInput)
}

class MealMenuViewModel: MealMenuViewModelType {
    var outputs: MealMenuViewModelOutput?
    private let disposeBag = DisposeBag()
    private var mealMenuText = BehaviorRelay<String>(value: "")
    private var kcalText = BehaviorRelay<String>(value: "")
    private var pSlider = BehaviorRelay<String>(value: "50.0")
    private var fSlider = BehaviorRelay<String>(value: "50.0")
    private var cSlider = BehaviorRelay<String>(value: "50.0")

    init() {
        outputs = self
    }

    // セットアップ
    func setup(input: MealMenuViewModelInput) {
        input.mealMenuTextField.subscribe(onNext: { [weak self] text in
            self?.mealMenuText.accept(text)
        }).disposed(by: disposeBag)
        input.kcalTextField.subscribe(onNext: { [weak self] text in
            self?.kcalText.accept(text)
        }).disposed(by: disposeBag)
        input.pSlider.subscribe(onNext: { [weak self] value in
            self?.pSlider.accept((self?.floatToString(float: value))!)
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.fSlider.subscribe(onNext: { [weak self] value in
            self?.fSlider.accept((self?.floatToString(float: value))!)
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.cSlider.subscribe(onNext: { [weak self] value in
            self?.cSlider.accept((self?.floatToString(float: value))!)
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.pPlusButton.subscribe(onNext: { [weak self] in
            self?.pSlider.accept(self!.plus(string: (self?.pSlider)!))
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.pMinusButton.subscribe(onNext: { [weak self] in
            self?.pSlider.accept(self!.minus(string: (self?.pSlider)!))
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.fPlusButton.subscribe(onNext: { [weak self] in
            self?.fSlider.accept(self!.plus(string: (self?.fSlider)!))
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.fMinusButton.subscribe(onNext: { [weak self] in
            self?.fSlider.accept(self!.minus(string: (self?.fSlider)!))
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.cPlusButton.subscribe(onNext: { [weak self] in
            self?.cSlider.accept(self!.plus(string: (self?.cSlider)!))
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
        input.cMinusButton.subscribe(onNext: { [weak self] in
            self?.cSlider.accept(self!.minus(string: (self?.cSlider)!))
            self?.kcalText.accept((self?.kcalNum())!)
        }).disposed(by: disposeBag)
    }

    // プラス
    func plus(string: BehaviorRelay<String>) -> String {
        var num = NSString(string: string.value).doubleValue
        if num < 100 {
            num += 0.1
        }
        let plus = String(format: "%.1F", num)
        return plus
    }

    // マイナス
    func minus(string: BehaviorRelay<String>) -> String {
        var num = NSString(string: string.value).doubleValue
        if num > 0 {
            num -= 0.1
        }
        let minus = String(format: "%.1F", num)
        return minus
    }

    // Stringに変換
    func floatToString(float: Float) -> String {
        let stre = String(format: "%.1F", float)
        return stre
    }

    // カロリー計算
    func kcalNum() -> String {
        let p = NSString(string: pSlider.value).doubleValue
        let f = NSString(string: fSlider.value).doubleValue
        let c = NSString(string: cSlider.value).doubleValue
        let num = p * 4 + f * 9 + c * 4
        let numString = String(format: "%.0F", num)
        return numString
    }
}

extension MealMenuViewModel: MealMenuViewModelOutput {
    var pPlus: Driver<String> {
        pSlider.asDriver()
    }

    var pMinus: Driver<String> {
        pSlider.asDriver()
    }

    var fPlus: Driver<String> {
        fSlider.asDriver()
    }

    var fMinus: Driver<String> {
        fSlider.asDriver()
    }

    var cPlus: Driver<String> {
        cSlider.asDriver()
    }

    var cMinus: Driver<String> {
        cSlider.asDriver()
    }

    var pValue: Driver<String> {
        pSlider.asDriver()
    }

    var fValue: Driver<String> {
        fSlider.asDriver()
    }

    var cValue: Driver<String> {
        cSlider.asDriver()
    }

    var mealMenu: Driver<String> {
        mealMenuText.asDriver()
    }

    var kcal: Driver<String> {
        kcalText.asDriver()
    }
}
