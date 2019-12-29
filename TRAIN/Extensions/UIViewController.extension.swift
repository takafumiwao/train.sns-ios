//
//  UIViewController.extension.swift
//  TRAIN
//
//  Created by Naoki Odajima on 2019/12/29.
//  Copyright © 2019 Naoki Odajima. All rights reserved.
//

import UIKit

extension UIViewController {
    /// storyboardからインスタンス化する
    public class func instantiateFromStoryboard<T: UIViewController>() -> T? {
        let storyboardName: String = String(describing: classForCoder())
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateInitialViewController() as? T
    }
}
