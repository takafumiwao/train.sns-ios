//
//  ArticleViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/04/12.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxSwift
import UIKit

class ArticleViewController: UIViewController {
    private let disposeBag = DisposeBag()
    // 投稿画像
    @IBOutlet weak var articleImage: UIImageView!
    // 投稿画像高さ
    @IBOutlet weak var articleImageHeight: NSLayoutConstraint!
    // 投稿画面のタップ
    @IBOutlet var articleImageTapGesture: UITapGestureRecognizer!
    // トレーニングメニュー追加ボタン
    @IBOutlet weak var articleTrainingMenu: UIButton!
    // トレーニングメニュー追加ボタン高さ
    @IBOutlet weak var articleTrainingMenuHeight: NSLayoutConstraint!
    // 食事メニュー追加ボタン
    @IBOutlet weak var articleMealMenu: UIButton!
    // 食事メニュー追加ボタン高さ
    @IBOutlet weak var articleMealMenuHeight: NSLayoutConstraint!
    // 投稿記事テキストビュー
    @IBOutlet weak var articleTextView: UITextView! {
        didSet {
            // デリゲート設定
            articleTextView.delegate = self
            // 最初の文字はPlaceHolderなので色は灰色
            articleTextView.textColor = .lightGray
        }
    }

    // 投稿記事テキストビュー高さ
    @IBOutlet weak var articleTextViewHeight: NSLayoutConstraint!
    // タグ追加ボタン
    @IBOutlet weak var articleTag: UIButton!
    // タグ追加ボタン高さ
    @IBOutlet weak var articleTagHeight: NSLayoutConstraint!
    // トレーニングメニュー作成スタックビュー
    @IBOutlet weak var articleTrainingMenuStackView: UIStackView!
    // 食事メニュー作成スタックビュー
    @IBOutlet weak var articleMealMenuStackView: UIStackView!
    // 投稿画面ビューモデル
    private var postViewModel: PostViewModel!
    // レイアウト設定プロパティ
    private lazy var initViewLayout: Void = {
        setLayout()
    }()

    // home画面に戻るボタン
    var dismissButton: UIBarButtonItem!
    // 投稿ボタン
    var articlePostButton: UIBarButtonItem!
    // 投稿画面の高さ
    var containerViewHeight: CGFloat?
    // スクロールビュー
    var scrollView: UIScrollView?
    // safeareaTopの高さ
    var areaTop: CGFloat?
    // safeareaBottomの高さ
    var areaBottom: CGFloat?
    // 投稿画面の高さ
    var containerViewConstraint: NSLayoutConstraint!
    // キーボードの高さを監視する変数
    var keyboardHeightObservable: Observable<CGFloat>?
    // トレーニングメニューを取得するキー
    private let trainingUserDefaultsKey = ["アームカール", "チンアップ", "ディップス", "プッシュダウン", "プルアップ", "ダンベルプルオーバー", "ワンハンドローイング", "ラットプルダウン", "デッドリフト", "インクラインダンベルプレス", "ベンチプレス", "ダンベルフライ", "デクラインダンベルフライ", "サイドレイズ", "ショルダープレス", "リアレイズ", "ネックエクステンション", "ダンベルシュラッグ", "スクワット", "レッグプレス", "レッグエクステンション", "アブドミナルクランチ", "トーソロウテーション", "ケーブルクランチ", "バーティカルベンチレッグレイズ", "バーベルプッシュクランチ"]

    override func viewDidLoad() {
        // 投稿画面のビューモデルの設定
        setupPostViewModel()
        // テキストが記入されるまで投稿できない
        articlePostButton.isEnabled = false
        // 投稿画像にタップ機能追加
        articleImage.addGestureRecognizer(articleImageTapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerViewHeight = view.frame.height - areaTop! - areaBottom!

        // トレーニングメニューを取得する
        for key in trainingUserDefaultsKey {
            if let trainingMenu = UserDefaults.standard.value(forKey: key) {
                let array = trainingMenu as! [[String]]
                createTrainingMenu(name: key, set: array[0], weight: array[1], count: array[2])
            }
        }
        // 食事メニューを取得する
        if let mealMenu = UserDefaults.standard.value(forKey: "Meal") {
            let array = mealMenu as! [[String]]

            for mealMenu in array {
                createMealMenu(mealMenu: mealMenu)
            }
        }
        // タグを取得する
        if let tag = UserDefaults.standard.value(forKey: "Tag") as? [String] {
            if tag == [] {
                articleTag.setTitle("タグを追加", for: .normal)
                return
            }
            var tags = ""
            var count = 0
            while count <= tag.count - 1 {
                if count != tag.count - 1 {
                    tags += tag[count].prefix(tag[count].count - 2)
                    tags += ", "
                } else {
                    tags += tag[count].prefix(tag[count].count - 2)
                }

                count += 1
            }
            articleTag.titleLabel?.numberOfLines = 0
            articleTag.titleLabel?.adjustsFontSizeToFitWidth = true
            articleTag.titleLabel?.minimumScaleFactor = 0.3
            articleTag.contentVerticalAlignment = .fill
            articleTag.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
            articleTag.setTitle(tags, for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // キーボドの設定・監視
        keyboardHeightObservable = keyboardHeight()
        keyboardHeightObservable?.subscribe(onNext: { [weak self] float in
            self?.scrollView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: float, right: 0)
            if float != 0 {
                self?.scrollView!.contentOffset.y = (self?.articleTextView.frame.origin.y)! + (self?.articleTextView.frame.height)! - float
            }
        }).disposed(by: disposeBag)
    }

    override func viewWillLayoutSubviews() {
        _ = initViewLayout
    }

    override func viewDidDisappear(_ animated: Bool) {
        // トレーニングメニュー追加処理
        for view in articleTrainingMenuStackView.subviews {
            view.removeFromSuperview()
            containerViewHeight! -= articleTrainingMenu.frame.height
        }
        // 食事メニュー追加処理
        for view in articleMealMenuStackView.subviews {
            view.removeFromSuperview()
            containerViewHeight! -= articleMealMenuStackView.frame.height
        }

        scrollView?.contentSize.height = containerViewHeight!
        containerViewConstraint.constant = containerViewHeight!
    }

    private func setLayout() {
        areaTop = view.safeAreaInsets.top
        areaBottom = view.safeAreaInsets.bottom
        let view = UIScreen.main.bounds.size.height - areaTop! - areaBottom! - 35
        articleImageHeight.constant = view * 3 / 7
        articleTrainingMenuHeight.constant = view / 14
        articleMealMenuHeight.constant = view / 14
        articleTextViewHeight.constant = view / 5
        articleTagHeight.constant = view / 14
        articleImage.layoutSublayers(of: customLayer(caLayer: articleImage.layer))
        articleTrainingMenu.layoutSublayers(of: customLayer(caLayer: articleTrainingMenu.layer))
        articleMealMenu.layoutSublayers(of: customLayer(caLayer: articleMealMenu.layer))
        articleTextView.layoutSublayers(of: customLayer(caLayer: articleTextView.layer))
        articleTag.layoutSublayers(of: customLayer(caLayer: articleTag.layer))
    }

    private func customLayer(caLayer: CALayer) -> CALayer {
        // CALayer設定
        caLayer.cornerRadius = 10.0
        caLayer.borderWidth = 1.0
        caLayer.borderColor = UIColor.darkGray.cgColor
        return caLayer
    }

    private func setupPostViewModel() {
        postViewModel = PostViewModel()
        let input = PostViewModelInput(trainingMenuButton: articleTrainingMenu.rx.tap.asObservable(), mealMenuButton: articleMealMenu.rx.tap.asObservable(), tagMenuButton: articleTag.rx.tap.asObservable(), dismissButton: dismissButton.rx.tap.asObservable(), imageTapGesture: articleImageTapGesture.rx.event.asObservable(), articlePostButton: articlePostButton.rx.tap.asObservable())
        postViewModel.setup(input: input)

        postViewModel.outputs?.storyBoardName.asDriver().drive(onNext: { name in

            if name == "CameraRollCollectionViewController" {
                self.tapImageView(storyboard: name)
            } else {
                self.goToNextView(storyboard: name)
            }

        }).disposed(by: disposeBag)

        postViewModel.outputs?.dismissFlg.asDriver().drive(onNext: { flg in
            UserDefaults.standard.removeAll()
            self.dismiss(animated: flg, completion: nil)
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

    private func goToNextView(storyboard: String) {
        // キーボード閉じる
        articleTextView.resignFirstResponder()
        // 画面遷移処理
        var storyBoard: UIStoryboard
        var nxViewController: UIViewController
        storyBoard = UIStoryboard(name: storyboard, bundle: nil)
        nxViewController = storyBoard.instantiateViewController(withIdentifier: storyboard)
        navigationController?.pushViewController(nxViewController, animated: true)
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

    func createTrainingMenu(name: String, set: [String], weight: [String], count: [String]) {
        // トレーニングメニューを追加
        if weight[0] == "", count[0] == "" { return }
        let newView = UIView()
        newView.layoutSublayers(of: customLayer(caLayer: newView.layer))
        newView.heightAnchor.constraint(equalToConstant: articleTrainingMenu.frame.height).isActive = true
        articleTrainingMenuStackView.spacing = 5
        articleTrainingMenuStackView.addArrangedSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        articleTrainingMenuStackView.addArrangedSubview(newView)
        containerViewHeight! += articleTrainingMenu.frame.height
        containerViewHeight! += 5
        scrollView?.translatesAutoresizingMaskIntoConstraints = false

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
        containerViewConstraint.constant = containerViewHeight!
        scrollView?.contentSize.height = containerViewHeight!
    }

    func createMealMenu(mealMenu: [String]) {
        // 食事メニューを追加
        let newView = UIView()
        newView.layoutSublayers(of: customLayer(caLayer: newView.layer))
        newView.heightAnchor.constraint(equalToConstant: articleMealMenu.frame.height).isActive = true
        articleMealMenuStackView.spacing = 5

        articleMealMenuStackView.addArrangedSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        containerViewHeight! += articleMealMenu.frame.height
        containerViewHeight! += 5
        scrollView?.translatesAutoresizingMaskIntoConstraints = false
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
        containerViewConstraint.constant = containerViewHeight!
        scrollView?.contentSize.height = containerViewHeight!
    }
}

extension ArticleViewController: UITextViewDelegate {
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
            articlePostButton.isEnabled = true
        }
    }
}
