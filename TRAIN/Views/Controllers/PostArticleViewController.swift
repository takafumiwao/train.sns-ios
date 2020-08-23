//
//  PostArticleViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/07/05.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxSwift
import UIKit

class PostArticleViewController: UIViewController {
    private let disposeBag = DisposeBag()

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.keyboardDismissMode = .interactive
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
        }
    }

    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTrainingMenu: UIButton!
    @IBOutlet weak var articleMealMenu: UIButton!
    @IBOutlet weak var articleText: UITextView! {
        didSet {
            // デリゲート設定
            articleText.delegate = self
            // 最初の文字はPlaceHolderなので色は灰色
            articleText.textColor = .lightGray
        }
    }

    @IBOutlet var articleImageTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var articleTagButton: UIButton!
    @IBOutlet weak var articleMealConstraint: NSLayoutConstraint!
    @IBOutlet weak var articleTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem! {
        didSet {
            postButton.isEnabled = false
        }
    }

    @IBOutlet weak var dismissButton: UIBarButtonItem!

    // 投稿画面ビューモデル
    private var postViewModel: PostViewModel!
    // 追加されたトレーニングメニューのViewの合計の高さ
    private var trainingTotalHeight: CGFloat = 0.0
    // 追加されたトレーニングメニューの個数
    private var trainingCount: Int = 0
    // 追加された食事メニューのViewの合計の高さ
    private var mealTotalHeight: CGFloat = 0.0
    // 追加された食事メニューの個数
    private var mealCount: Int = 0

    private var tag: Int = 0
    // キーボードの高さを監視する変数
    private var keyboardHeightObservable: Observable<CGFloat>?

    // MARK: トレーニングメニューを取得するキー -> APIで取得するようになる

    private let trainingUserDefaultsKey = ["アームカール", "チンアップ", "ディップス", "プッシュダウン", "プルアップ", "ダンベルプルオーバー", "ワンハンドローイング", "ラットプルダウン", "デッドリフト", "インクラインダンベルプレス", "ベンチプレス", "ダンベルフライ", "デクラインダンベルフライ", "サイドレイズ", "ショルダープレス", "リアレイズ", "ネックエクステンション", "ダンベルシュラッグ", "スクワット", "レッグプレス", "レッグエクステンション", "アブドミナルクランチ", "トーソロウテーション", "ケーブルクランチ", "バーティカルベンチレッグレイズ", "バーベルプッシュクランチ"]

    override func viewDidLoad() {
        super.viewDidLoad()
        userDefaultsClear()
        // 各パーツの設定
        settingParts()
        // ビューモデルの設定
        setupPostViewModel()
    }

    private func userDefaultsClear() {
        // UserDefaultsに保存しているデータを削除する
        UserDefaults.standard.removeObject(forKey: "Tags")
        UserDefaults.standard.removeObject(forKey: "Meal")
        UserDefaults.standard.removeObject(forKey: "checkmarkArray")
        trainingUserDefaultsKey.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // キーボドの設定・監視
        keyboardHeightObservable = keyboardHeight()
        keyboardHeightObservable?.subscribe(onNext: { [weak self] float in
            self?.scrollView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: float, right: 0)
            if float != 0 {
                self?.scrollView!.contentOffset.y = (self?.articleText.frame.origin.y)! + (self?.articleText.frame.height)! - float
            }
        }).disposed(by: disposeBag)
    }

    private func keyboardHeight() -> Observable<CGFloat> {
        Observable
            .from([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                    },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { _ -> CGFloat in
                        0
                    }
            ])
            .merge()
    }

    private func setupPostViewModel() {
        postViewModel = PostViewModel()
        let input = PostViewModelInput(trainingMenuButton: articleTrainingMenu.rx.tap.asObservable(), mealMenuButton: articleMealMenu.rx.tap.asObservable(), tagMenuButton: articleTagButton.rx.tap.asObservable(), dismissButton: dismissButton.rx.tap.asObservable(), imageTapGesture: articleImageTapGesture.rx.event.asObservable(), articlePostButton: postButton.rx.tap.asObservable())
        postViewModel.setup(input: input)

        postViewModel.outputs.storyboardName.asDriver().drive(onNext: { name in

            if name == "CameraRollCollectionViewController" {
                self.tapImageView(storyboard: name)
            } else {
                self.goToNextView(storyboard: name)
            }

        }).disposed(by: disposeBag)

        postViewModel.outputs.dismissFlg.drive(onNext: { [weak self] flg in
            // 投稿画面を閉じる
            self?.dismiss(animated: flg, completion: nil)
        }).disposed(by: disposeBag)
    }

    private func tapImageView(storyboard: String) {
        //  画面遷移処理
        let storyBoard = UIStoryboard(name: "CameraRollCollectionViewController", bundle: nil)
        let nxViewController = storyBoard.instantiateViewController(identifier: "CameraRollCollectionViewController") as! CameraRollCollectionViewController
        nxViewController.currentPhoto.subscribe(onNext: { [weak self] photo in
            DispatchQueue.main.async {
                self?.updateUI(with: photo)
            }
        }).disposed(by: disposeBag)
        navigationController?.pushViewController(nxViewController, animated: true)
    }

    private func updateUI(with image: UIImage) {
        // 画像をセット
        articleImage.image = image
        articleImage.contentMode = .scaleAspectFill
    }

    private func goToNextView(storyboard: String) {
        // キーボード閉じる
        articleText.resignFirstResponder()
        // 画面遷移処理
        var storyBoard: UIStoryboard
        var nxViewController: UIViewController
        storyBoard = UIStoryboard(name: storyboard, bundle: nil)
        nxViewController = storyBoard.instantiateViewController(withIdentifier: storyboard)
        navigationController?.pushViewController(nxViewController, animated: true)
    }

    // トレーニングメニューのStackViewを作成するメソッド
    private func createTrainingMenu(name: String, set: [String], weight: [String], count: [String]) {
        if weight[0].isEmpty, count[0].isEmpty { return }
        // トレーニングメニューを追加
        tag += 1
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: articleTrainingMenu.frame.width, height: articleTrainingMenu.frame.height))
        newView.layoutSublayers(of: customLayer(caLayer: newView.layer))
        scrollView.addSubview(newView)
        newView.tag = tag
        newView.frame.origin.x = articleTrainingMenu.frame.origin.x
        newView.frame.origin.y = trainingTotalHeight + 10
        trainingTotalHeight = newView.frame.origin.y + newView.frame.height

        let trainingMenuLabel = UILabel()
        trainingMenuLabel.font = UIFont.systemFont(ofSize: 16)
        newView.addSubview(trainingMenuLabel)
        trainingMenuLabel.text = name
        trainingMenuLabel.translatesAutoresizingMaskIntoConstraints = false
        trainingMenuLabel.leftAnchor.constraint(equalTo: newView.leftAnchor, constant: 5).isActive = true
        let horizonalStackView = UIStackView()
        horizonalStackView.axis = .horizontal
        horizonalStackView.spacing = 20
        newView.addSubview(horizonalStackView)
        horizonalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizonalStackView.bottomAnchor.constraint(equalTo: newView.bottomAnchor, constant: -5).isActive = true
        horizonalStackView.centerXAnchor.constraint(equalTo: newView.centerXAnchor, constant: 0).isActive = true
        var counter = 0
        for _ in 0 ... set.count {
            if counter == 3 { break }
            if weight[counter] == "", count[counter] == "" { break }
            let label = UILabel()
            label.text = "\(weight[counter])kg ✖︎ \(count[counter])回"

            horizonalStackView.addArrangedSubview(label)
            label.minimumScaleFactor = 0.3
            label.sizeToFit()
            counter += 1
        }
    }

    // 食事メニューのStackViewを作成するメソッド
    private func createMealMenu(mealMenu: [String]) {
        // 食事メニューを追加
        tag += 1
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: articleMealMenu.frame.width, height: articleMealMenu.frame.height))
        newView.tag = tag
        newView.layoutSublayers(of: customLayer(caLayer: newView.layer))
        scrollView.addSubview(newView)
        newView.frame.origin.x = articleMealMenu.frame.origin.x
        newView.frame.origin.y = mealTotalHeight + 10
        mealTotalHeight = newView.frame.origin.y + newView.frame.height
        let mealMenuText = "\(mealMenu[0])    P:\(mealMenu[2]) F:\(mealMenu[3]) C:\(mealMenu[4])    \(mealMenu[1])kcal"
        let label = UILabel()
        label.text = mealMenuText
        label.textAlignment = .center
        let horizonalStackView = UIStackView()
        horizonalStackView.axis = .horizontal
        newView.addSubview(horizonalStackView)
        horizonalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizonalStackView.widthAnchor.constraint(equalTo: newView.widthAnchor, constant: 0).isActive = true

        horizonalStackView.centerXAnchor.constraint(equalTo: newView.centerXAnchor, constant: 0).isActive = true
        horizonalStackView.centerYAnchor.constraint(equalTo: newView.centerYAnchor, constant: 0).isActive = true
        horizonalStackView.addArrangedSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
    }

    private func customLayer(caLayer: CALayer) -> CALayer {
        // CALayer設定
        caLayer.cornerRadius = 10.0
        caLayer.borderWidth = 1.0
        caLayer.borderColor = UIColor.darkGray.cgColor
        return caLayer
    }

    private func trainingUpdateLayouts() {
        articleMealConstraint.constant = (articleTrainingMenu.frame.height + 10) * CGFloat(trainingCount) + 10
    }

    private func mealUpdateLayouts() {
        articleTextConstraint.constant = (articleMealMenu.frame.height + 10) * CGFloat(mealCount) + 10
    }
}

extension PostArticleViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "メッセージを書いてください"
            textView.textColor = UIColor.lightGray
        } else {
            // テキストが空でない場合、投稿可能とする
            postButton.isEnabled = true
        }
    }

    func settingParts() {
        trainingUpdateLayouts()
        mealUpdateLayouts()
        trainingTotalHeight = 0.0
        trainingCount = 0
        mealTotalHeight = 0.0
        mealCount = 0
        if tag != 0 {
            var tagCount = 1
            scrollView.subviews.forEach { view in
                if view.tag > 0 {
                    print(view)
                    view.removeFromSuperview()
                    tagCount += 1
                }
                view.subviews.forEach { sub in
                    if sub.tag > 0 {
                        print(sub)
                        sub.removeFromSuperview()
                        tagCount += 1
                    }
                }
            }

            tag = 0
        }

        articleImage.layoutSublayers(of: customLayer(caLayer: articleImage.layer))
        articleTrainingMenu.layoutSublayers(of: customLayer(caLayer: articleTrainingMenu.layer))
        articleMealMenu.layoutSublayers(of: customLayer(caLayer: articleMealMenu.layer))
        articleText.layoutSublayers(of: customLayer(caLayer: articleText.layer))
        articleTagButton.layoutSublayers(of: customLayer(caLayer: articleTagButton.layer))
        // トレーニングメニューを取得する
        trainingTotalHeight = articleTrainingMenu.frame.height + articleTrainingMenu.frame.origin.y
        for key in trainingUserDefaultsKey {
            if let trainingMenu = UserDefaults.standard.value(forKey: key) {
                let array = trainingMenu as! [[String]]
                createTrainingMenu(name: key, set: array[0], weight: array[1], count: array[2])
                trainingCount += 1
            }
        }

        trainingUpdateLayouts()
        scrollView.layoutIfNeeded()
        // 食事メニューを取得する
        mealTotalHeight = articleMealMenu.frame.height + articleMealMenu.frame.origin.y

        if let mealMenu = UserDefaults.standard.value(forKey: "Meal") {
            let array = mealMenu as! [[String]]
            mealCount = array.count
            for mealMenu in array {
                createMealMenu(mealMenu: mealMenu)
            }
        }

        mealUpdateLayouts()

        // タグがある場合はボタンに追加する
        if let tag = UserDefaults.standard.value(forKey: "Tags") as? [String] {
            if tag.isEmpty {
                articleTagButton.setTitle("タグを追加", for: .normal)
                return
            }

            var tags = ""

            tag.forEach { t in
                tags += t
                tags += ","
            }

            tags = String(tags.dropLast())
            articleTagButton.setTitle(tags, for: .normal)
            articleTagButton.titleLabel?.lineBreakMode = .byTruncatingTail
            articleTagButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
}

extension PostArticleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}
