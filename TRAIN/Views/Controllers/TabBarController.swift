//
//  TabBarController.swift
//  TRAIN
//
//  Created by Naoki Odajima on 2019/12/29.
//  Copyright © 2019 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class TabBarController: UITabBarController {
    private let disposeBag = DisposeBag()
    // 投稿画面に遷移するボタン
    private let postButton = UIButton()
    // safeArea
    var topSafeAreaHeight: CGFloat = 0
    var bottomSafeAreaHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // ボタンタップされたら投稿画面へ遷移
        postButton.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.goToPostView()
        }).disposed(by: disposeBag)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // safeArea取得
        topSafeAreaHeight = view.safeAreaInsets.top
        bottomSafeAreaHeight = view.safeAreaInsets.bottom
        // postButtonの設定
        postButton.frame.size = CGSize(width: view.frame.width / 5, height: view.frame.width / 5)
        postButton.frame.origin.y = tabBar.frame.origin.y - (tabBar.frame.height - bottomSafeAreaHeight) / 1.5
        postButton.center.x = view.frame.width / 2
        postButton.setImage(UIImage(systemName: "camera"), for: .normal)
        postButton.layer.cornerRadius = postButton.frame.size.width / 2
        postButton.backgroundColor = UIColor.white
        postButton.layer.shadowOpacity = 0.2
        postButton.layer.shadowRadius = postButton.frame.size.width / 2
        postButton.layer.shadowColor = UIColor.black.cgColor
        postButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.addSubview(postButton)
        // tabBarアイテムの位置を変更する
        tabBar.itemPositioning = .centered
        tabBar.itemSpacing = view.frame.width / 3.1
        tabBar.itemWidth = view.frame.width / 3
    }

    func goToPostView() {
        // 画面遷移処理
        let storyBoard = UIStoryboard(name: "PostViewController", bundle: nil)
        let nxViewController = storyBoard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        let nav = UINavigationController(rootViewController: nxViewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}
