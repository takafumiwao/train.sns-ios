//
//  PostViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/24.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class PostViewController: UIViewController {
    // screenSize
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    private var disposeBag = DisposeBag()
    private var postViewModel: PostViewModel!
    private let imageTapGesture = UITapGestureRecognizer()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var trainingMenuButton: UIButton!
    @IBOutlet weak var mealMenuButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tagButton: UIButton!
    private lazy var initViewLayout: Void = {
        setLayout()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.text = ""
        bindScrollTextViewWhenShowKeyboard()
        setupPostViewModel()
        imageView.addGestureRecognizer(imageTapGesture)
    }

    private func setupPostViewModel() {
        postViewModel = PostViewModel()
        let input = PostViewModelInput(trainingMenuButton: trainingMenuButton.rx.tap.asObservable(), mealMenuButton: mealMenuButton.rx.tap.asObservable(), tagMenuButton: tagButton.rx.tap.asObservable(), dismissButton: dismissButton.rx.tap.asObservable(), imageTapGesture: imageTapGesture.rx.event.asObservable())
        postViewModel.setup(input: input)

        postViewModel.outputs?.storyBoardName.asDriver().drive(onNext: { name in

            if name == "CameraRollCollectionViewController" {
                self.tapImageView(storyboard: name)
            } else {
                self.goToNextView(storyboard: name)
            }

        }).disposed(by: disposeBag)

        postViewModel.outputs?.dismissFlg.asDriver().drive(onNext: { flg in
            self.dismiss(animated: flg, completion: nil)
        }).disposed(by: disposeBag)
    }

    private func goToNextView(storyboard: String) {
        // キーボード閉じる
        textView.resignFirstResponder()
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

    @objc func keyboradClose(_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = initViewLayout
    }

    private func setLayout() {
        // 画面サイズ取得
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        // レイアウト設定
        imageView.frame = CGRect(x: screenWidth / 28, y: screenWidth / 28, width: screenWidth - (screenWidth / 14), height: screenHeight / 2.5)
        trainingMenuButton.frame = CGRect(x: screenWidth / 28, y: imageView.frame.origin.y + imageView.frame.height + screenWidth / 28, width: screenWidth - (screenWidth / 14), height: screenHeight / 14)
        mealMenuButton.frame = CGRect(x: screenWidth / 28, y: trainingMenuButton.frame.origin.y + trainingMenuButton.frame.height + screenWidth / 28, width: screenWidth - (screenWidth / 14), height: screenHeight / 14)
        textView.frame = CGRect(x: screenWidth / 28, y: mealMenuButton.frame.origin.y + mealMenuButton.frame.height + screenWidth / 28, width: screenWidth - (screenWidth / 14), height: screenHeight / 7)
        tagButton.frame = CGRect(x: screenWidth / 28, y: textView.frame.origin.y + textView.frame.height + screenWidth / 28, width: screenWidth - (screenWidth / 14), height: screenHeight / 14)
        imageView.layoutSublayers(of: customLayer(caLayer: imageView.layer))
        trainingMenuButton.layoutSublayers(of: customLayer(caLayer: trainingMenuButton.layer))
        mealMenuButton.layoutSublayers(of: customLayer(caLayer: mealMenuButton.layer))
        textView.layoutSublayers(of: customLayer(caLayer: textView.layer))
        tagButton.layoutSublayers(of: customLayer(caLayer: tagButton.layer))
        scrollView.addSubview(imageView)
        scrollView.addSubview(trainingMenuButton)
        scrollView.addSubview(mealMenuButton)
        scrollView.addSubview(textView)
        scrollView.addSubview(tagButton)
        scrollView.frame = view.frame
        scrollView.contentSize.height = imageView.frame.height + mealMenuButton.frame.height + textView.frame.height + tagButton.frame.height
    }

    private func customLayer(caLayer: CALayer) -> CALayer {
        // CALayer設定
        caLayer.cornerRadius = 10.0
        caLayer.borderWidth = 1.0
        caLayer.borderColor = UIColor.darkGray.cgColor
        return caLayer
    }

    // 画像をセット
    private func updateUI(with image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
    }

    // 食事メニュー追加
    func addMealMenu(name: String, kcal: String, p: String, f: String, c: String) {}

    // トレーニングメニュー追加
    func addTrainingMenu() {}
}

extension PostViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {}
}

extension PostViewController {
    // キーボードが現れたときに、テキストビューをスクロールする
    func bindScrollTextViewWhenShowKeyboard() {
        var disposeBag: DisposeBag? = DisposeBag()

        // この関数内で完結するように、dealloc時にdisposeしてくれる仕組みを用意する
        rx.deallocating
            .subscribe(onNext: { _ in
                disposeBag = nil
            })
            .disposed(by: disposeBag!)

        // viewAppearの間だけUIKeyboardが発行するNotificationを受け取るObserbaleを作る
        viewAppearedObservable()
            .flatMapLatest { event -> Observable<(Bool, Notification)> in
                if event {
                    // notificationは、(true=表示/false=非表示, NSNotification)のタプルで次のObservableに渡す
                    return Observable.of(
                        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification) // Swift4.2〜 UIResponder.keyboardWillShowNotification
                            .map { (true, $0) },
                        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification) // Swift4.2〜 UIResponder.keyboardWillHideNotification
                            .map { (false, $0) }
                    ).merge()
                } else {
                    return Observable<(Bool, Notification)>.empty()
                }
            }
            .subscribe(onNext: { [weak self] (isShow: Bool, notification: Notification) in
                // notificationに対して、適切にスクロールする処理
                guard let self = self else { return }
                if isShow {
                    self.keyboardWillBeShown(notification: notification)
                } else {
                    self.restoreScrollViewSize(notification: notification)
                }
            })
            .disposed(by: disposeBag!)
    }

    /// キーボード表示時にTextViewの位置を変更
    private func keyboardWillBeShown(notification: Notification) {
        guard let textView = self.view.currentFirstResponder() as? UIView,
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else { return }

        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero

        // textViewの画面上の絶対座標
        let textViewAbsPoint = textView.absPoint

        // 画面サイズ
        let screenSize = UIScreen.main.bounds.size

        // textViewの底の位置の座標
        let textPosition = textViewAbsPoint.y + textView.frame.height

        // キーボード位置
        let keyboardPosition = screenSize.height - keyboardFrame.size.height

        // 移動判定
        if textPosition >= keyboardPosition {
            // 移動距離
            let offsetY = textPosition - keyboardPosition

            // 移動
            UIView.animate(withDuration: TimeInterval(truncating: animationDuration)) {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offsetY * 2, right: 0) // いらないかも
                self.scrollView.contentInset = contentInsets // いらないかも
                self.scrollView.scrollIndicatorInsets = contentInsets // いらないかも
                self.scrollView.contentOffset = CGPoint(x: 0, y: offsetY * 2)
            }
        }
    }

    /// TextViewを元の位置に戻す
    private func restoreScrollViewSize(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension UIView {
    // 親ビューをたどってFirstResponderを探す
    func currentFirstResponder() -> UIResponder? {
        if isFirstResponder {
            return self
        }

        for view in subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }

        return nil
    }

    // 任意の型の親ビューを探す
    // 親をたどってScrollViewを探す場合などに使用する
    func findSuperView<T>(ofType: T.Type) -> T? {
        if let superView = self.superview {
            switch superView {
            case let superView as T:
                return superView
            default:
                return superView.findSuperView(ofType: ofType)
            }
        }

        return nil
    }

    /// 画面中の絶対座標
    var absPoint: CGPoint {
        var point = CGPoint(x: frame.origin.x, y: frame.origin.y)

        if let superview = self.superview {
            let addPoint = superview.absPoint
            point = CGPoint(x: point.x + addPoint.x, y: point.y + addPoint.y)
        }

        return point
    }
}

extension PostViewController {
    /// trigger event
    private func trigger(selector: Selector) -> Observable<Void> {
        rx.sentMessage(selector).map { _ in () }.share(replay: 1)
    }

    var viewDidAppearTrigger: Observable<Void> {
        trigger(selector: #selector(viewDidAppear(_:)))
    }

    var viewDidDisappearTrigger: Observable<Void> {
        trigger(selector: #selector(viewDidDisappear(_:)))
    }

    func viewAppearedObservable() -> Observable<Bool> {
        Observable.of(
            viewDidAppearTrigger.map { true },
            viewDidDisappearTrigger.map { false }
        )
        .merge()
    }
}
