//
//  AuthModalViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/05/06.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import AuthenticationServices
import RxSwift
import UIKit

class AuthModalViewController: UIViewController {
    private let disposeBag = DisposeBag()
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var faceBookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var termsOfServiceButton: UIButton!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 閉じるボタン
        dismissButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)

        // SignWithApple
        appleButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.authorizationAppleID()
        }).disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // レイアウト設定
        let areaTop = view.safeAreaInsets.top
        let areaBottom = view.safeAreaInsets.bottom
        let safeArea = view.frame.height - areaTop - areaBottom
        let margin = safeArea / 20
        let center = view.frame.width / 2

        var width: CGFloat = 20
        var height: CGFloat = 20
        var originY: CGFloat = 0.0

        dismissButton.frame = CGRect(x: view.frame.width - (dismissButton.frame.width * 1.5), y: margin, width: width, height: height)
        width = (view.frame.width * 2) / 3
        height = safeArea / 12

        var rect: CGSize = headerLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        // ログインラベル
        headerLabel.frame = CGRect(x: 0, y: margin, width: rect.width, height: rect.height)
        headerLabel.center.x = center
        originY = headerLabel.frame.height + headerLabel.frame.origin.y + margin
        // Facebookボタン
        faceBookButton.frame = CGRect(x: 0, y: originY, width: width, height: height)
        faceBookButton.center.x = center
        faceBookButton.layer.cornerRadius = 10
        originY = faceBookButton.frame.height + faceBookButton.frame.origin.y + margin
        // Twitterボタン
        twitterButton.frame = CGRect(x: 0, y: originY, width: width, height: height)
        twitterButton.center.x = center
        twitterButton.layer.cornerRadius = 10
        originY = twitterButton.frame.height + twitterButton.frame.origin.y + margin
        // AppleSignInボタン
        appleButton.frame = CGRect(x: 0, y: originY, width: width, height: height)
        appleButton.center.x = center
        appleButton.layer.cornerRadius = 10
        originY = appleButton.frame.height + appleButton.frame.origin.y + margin
        width = view.frame.width / 4
        // 利用規約ボタン
        termsOfServiceButton.frame = CGRect(x: 0, y: originY, width: width, height: height)
        termsOfServiceButton.center.x = center
        termsOfServiceButton.layer.cornerRadius = 10
        originY = termsOfServiceButton.frame.origin.y + termsOfServiceButton.frame.height + margin
        width = (view.frame.width * 2) / 3

        rect = middleLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        // 新規登録ラベル
        middleLabel.frame = CGRect(x: 0, y: originY, width: rect.width, height: rect.height)
        middleLabel.center.x = center
        originY = middleLabel.frame.height + middleLabel.frame.origin.y + margin
        // 新規登録ボタン
        signUpButton.frame = CGRect(x: 0, y: originY, width: width, height: height)
        signUpButton.center.x = center
        signUpButton.layer.borderColor = UIColor.black.cgColor
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.cornerRadius = 10
    }

    private func authorizationAppleID() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

extension AuthModalViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 　取得できる値
            let userIdentifier = appleIDCredential.user

            // userDefaultsに保存する
            UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")

            // 取得できた場合、画面遷移を行う
            dismiss(animated: true, completion: nil)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // エラー処理
        print(error)
    }
}

extension AuthModalViewController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}
