//
//  UserDefaults.extension.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/04/04.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Foundation

extension UserDefaults {
    // UserDefautsの全ての値を削除する
    func removeAll() {
        dictionaryRepresentation().forEach { removeObject(forKey: $0.key) }
    }
}
