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
        let areaTop = view.safeAreaInsets.top
        let areaBottom = view.safeAreaInsets.bottom
        let safeArea = view.frame.height - areaTop - areaBottom
        var rect: CGSize = headerLabel.sizeThatFits(CGSize(width: (view.frame.width * 2) / 3, height: CGFloat.greatestFiniteMagnitude))
        headerLabel.frame = CGRect(x: 0, y: safeArea / 20, width: rect.width, height: rect.height)
        headerLabel.center.x = view.frame.width / 2
        dismissButton.frame = CGRect(x: view.frame.width - (dismissButton.frame.width * 1.5), y: safeArea / 40, width: 20, height: 20)
        faceBookButton.frame = CGRect(x: 0, y: headerLabel.frame.height + headerLabel.frame.origin.y + (safeArea / 20), width: (view.frame.width * 2) / 3, height: safeArea / 12)
        faceBookButton.center.x = view.frame.width / 2
        faceBookButton.layer.cornerRadius = 10
        twitterButton.frame = CGRect(x: 0, y: faceBookButton.frame.height + faceBookButton.frame.origin.y + (safeArea / 20), width: (view.frame.width * 2) / 3, height: safeArea / 12)
        twitterButton.center.x = view.frame.width / 2
        twitterButton.layer.cornerRadius = 10
        appleButton.frame = CGRect(x: 0, y: twitterButton.frame.height + twitterButton.frame.origin.y + (safeArea / 20), width: (view.frame.width * 2) / 3, height: safeArea / 12)
        appleButton.center.x = view.frame.width / 2
        appleButton.layer.cornerRadius = 10
        termsOfServiceButton.frame = CGRect(x: 0, y: appleButton.frame.height + appleButton.frame.origin.y + (safeArea / 40), width: view.frame.width / 4, height: safeArea / 12)
        termsOfServiceButton.center.x = view.frame.width / 2
        termsOfServiceButton.layer.cornerRadius = 10
        rect = middleLabel.sizeThatFits(CGSize(width: (view.frame.width * 2) / 3, height: CGFloat.greatestFiniteMagnitude))
        middleLabel.frame = CGRect(x: 0, y: termsOfServiceButton.frame.origin.y + termsOfServiceButton.frame.height + (safeArea / 40), width: rect.width, height: rect.height)
        middleLabel.center.x = view.frame.width / 2
        signUpButton.frame = CGRect(x: 0, y: middleLabel.frame.height + middleLabel.frame.origin.y + (safeArea / 20), width: (view.frame.width * 2) / 3, height: safeArea / 12)
        signUpButton.center.x = view.frame.width / 2
        signUpButton.layer.borderColor = UIColor.black.cgColor
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.cornerRadius = 10
    }

    func authorizationAppleID() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }
}

extension AuthModalViewController: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
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

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // エラー処理
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
