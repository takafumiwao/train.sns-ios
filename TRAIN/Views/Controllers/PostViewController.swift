//
//  PostViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/24.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var postButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {}

    @IBAction func backHome(_ sender: Any) {
        // Home画面に戻る
        dismiss(animated: true, completion: nil)
    }
}
