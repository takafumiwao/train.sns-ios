//
//  UITableView.extension.swift
//  TRAIN
//
//  Created by Naoki Odajima on 2019/12/29.
//  Copyright © 2019 Naoki Odajima. All rights reserved.
//

import UIKit

extension UITableView {
    /// UITableViewのregisterと同じ。コードファイルとxibファイルのファイル名を揃える必要がある
    public func register(nibCellType: UITableViewCell.Type) {
        let nibName: String = String(describing: nibCellType.classForCoder())
        let nib: UINib = UINib(nibName: nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: nibName)
    }
    
    /// UITableViewのdequeueReusableCellと同じ。コードファイルとxibファイルのファイル名を揃える必要がある
    public func dequeueReusableCell<T: UITableViewCell>(_ cellType: UITableViewCell.Type, for indexPath: IndexPath) -> T? {
        let identifier: String = String(describing: cellType.classForCoder())
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
    }
}
