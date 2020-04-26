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
    // storyBoardの名前
    var storyBoardName: Driver<String> { get }
    // ホームへ戻る際のパラメータ
    var dismissFlg: Driver<Bool> { get }
    // ホームへ戻る際のパラメータ
    var articlePostFlg: Driver<Bool> { get }
}

protocol PostViewModelType {
    var outputs: PostViewModelOutput? { get }
    func setup(input: PostViewModelInput)
}

class PostViewModel: PostViewModelType {
    var outputs: PostViewModelOutput?
    private let disposeBag = DisposeBag()
    private let storyBoard = BehaviorRelay<String>(value: "")
    private let dismiss = BehaviorRelay<Bool>(value: false)
    private let articlePost = BehaviorRelay<Bool>(value: false)

    init() {
        outputs = self
    }

    // storyBoard名をenumで管理
    enum StoryBoard: String {
        case CameraRoll = "CameraRollCollectionViewController"
        case SelectImage = "SelectImageViewController"
        case TrainingMenu = "TraininngMenuViewController"
        case MealMenu = "MealMenuViewController"
        case TagView = "TagViewController"
    }

    // セットアップ
    func setup(input: PostViewModelInput) {
        input.trainingMenuButton.subscribe(onNext: { [weak self] in
            self?.getStoryBoardName(name: StoryBoard.TrainingMenu.rawValue)
        }).disposed(by: disposeBag)

        input.mealMenuButton.subscribe(onNext: { [weak self] in
            self?.getStoryBoardName(name: StoryBoard.MealMenu.rawValue)
        }).disposed(by: disposeBag)

        input.tagMenuButton.subscribe(onNext: { [weak self] in
            self?.getStoryBoardName(name: StoryBoard.TagView.rawValue)
        }).disposed(by: disposeBag)

        input.dismissButton.subscribe { _ in
            self.dismiss.accept(true)
        }.disposed(by: disposeBag)

        input.imageTapGesture.subscribe { _ in
            self.getStoryBoardName(name: StoryBoard.CameraRoll.rawValue)
        }.disposed(by: disposeBag)

        input.articlePostButton.subscribe { _ in

            // MARK: 投稿処理

            self.dismiss.accept(true)
        }.disposed(by: disposeBag)
    }

    private func getStoryBoardName(name: String) {
        storyBoard.accept(name)
    }
}

extension PostViewModel: PostViewModelOutput {
    var storyBoardName: Driver<String> {
        storyBoard.filter { (name) -> Bool in
            name != ""
        }.asDriver(onErrorJustReturn: "")
    }

    var dismissFlg: Driver<Bool> {
        dismiss.filter { (flg) -> Bool in
            flg
        }.asDriver(onErrorJustReturn: false)
    }

    var articlePostFlg: Driver<Bool> {
        articlePost.filter { (flg) -> Bool in
            flg
        }.asDriver(onErrorJustReturn: false)
    }
}
