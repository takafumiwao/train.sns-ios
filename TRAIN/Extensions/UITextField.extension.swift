//
//  UITextField.extension.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/28.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import UIKit

extension UITextField {
    // アンダーラインの設定
    func underlined() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: frame.size.height + 6.0, width: frame.size.width, height: 1.0)
        border.borderWidth = width
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}
