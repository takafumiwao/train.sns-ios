//
//  ArticlePostViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/04/12.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxSwift
import UIKit

class ArticlePostViewController: UIViewController {
    private let disposeBag = DisposeBag()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var articlePostButton: UIBarButtonItem!

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.keyboardDismissMode = .interactive
            scrollView.showsVerticalScrollIndicator = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        containerViewHeight.constant = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext" {
            let nxVC = segue.destination as! ArticleViewController
            nxVC.dismissButton = dismissButton
            nxVC.scrollView = scrollView
            nxVC.containerViewConstraint = containerViewHeight
            nxVC.articlePostButton = articlePostButton
        }
    }
}
