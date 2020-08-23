//
//  IPostViewModel.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/25.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift

struct PostViewModelInput {
    // トレーニングメニューへ遷移するボタン
    let trainingMenuButton: Observable<Void>
    // 食事メニューへ遷移するボタン
    let mealMenuButton: Observable<Void>
    // タグメニューへ遷移するボタン
    let tagMenuButton: Observable<Void>
    // ホームへ戻るボタン
    let dismissButton: Observable<Void>
    // imageViewのtapGesture
    let imageTapGesture: Observable<UITapGestureRecognizer>
    // 投稿ボタン
    let articlePostButton: Observable<Void>
}

protocol PostViewModelOutput {
    // storyboardの名前
    var storyboardName: Driver<String> { get }
    // ホームへ戻る際のパラメータ
    var dismissFlg: Driver<Bool> { get }
    // ホームへ戻る際のパラメータ
    var articlePostFlg: Driver<Bool> { get }
}

protocol PostViewModelType {
    var outputs: PostViewModelOutput { get }
    func setup(input: PostViewModelInput)
}

class PostViewModel: PostViewModelType {
    var outputs: PostViewModelOutput { self }
    private let disposeBag = DisposeBag()
    private let storyboard = BehaviorRelay<String>(value: "")
    private let dismiss = BehaviorRelay<Bool>(value: false)
    private let articlePost = BehaviorRelay<Bool>(value: false)

    // Storyboard名をenumで管理
    enum Storyboard: String {
        case CameraRoll = "CameraRollCollectionViewController"
        case SelectImage = "SelectImageViewController"
        case TrainingMenu = "TraininngMenuViewController"
        case MealMenu = "MealMenuViewController"
        case TagView = "AddTagListViewController"
    }

    // セットアップ
    func setup(input: PostViewModelInput) {
        input.trainingMenuButton.subscribe(onNext: { [weak self] in
            self?.storyboardAccept(name: Storyboard.TrainingMenu.rawValue)
        }).disposed(by: disposeBag)

        input.mealMenuButton.subscribe(onNext: { [weak self] in
            self?.storyboardAccept(name: Storyboard.MealMenu.rawValue)
        }).disposed(by: disposeBag)

        input.tagMenuButton.subscribe(onNext: { [weak self] in
            self?.storyboardAccept(name: Storyboard.TagView.rawValue)
        }).disposed(by: disposeBag)

        input.dismissButton.subscribe { _ in
            self.dismiss.accept(true)
        }.disposed(by: disposeBag)

        input.imageTapGesture.subscribe { _ in
            self.storyboardAccept(name: Storyboard.CameraRoll.rawValue)
        }.disposed(by: disposeBag)

        input.articlePostButton.subscribe { [weak self] in

            // MARK: 投稿処理

            self?.dismiss.accept(true)
        }.disposed(by: disposeBag)
    }

    func storyboardAccept(name: String) {
        storyboard.accept(name)
    }
}

extension PostViewModel: PostViewModelOutput {
    var storyboardName: Driver<String> {
        storyboard.filter { !$0.isEmpty }.asDriver(onErrorJustReturn: "")
    }

    var dismissFlg: Driver<Bool> {
        dismiss.filter { $0 }.asDriver(onErrorJustReturn: false)
    }

    var articlePostFlg: Driver<Bool> {
        articlePost.filter { $0 }.asDriver(onErrorJustReturn: false)
    }
}
