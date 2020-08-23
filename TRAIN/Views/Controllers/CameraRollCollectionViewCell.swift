//
//  CameraViewCollectionViewCell.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/22.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Photos
import UIKit

class CameraRollCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    // Cellで入れる画像のPHImageRequestID
    var requestId: PHImageRequestID?

    override func prepareForReuse() {
        super.prepareForReuse()
        // imageViewの初期化
        imageView.image = nil
        requestId = nil
    }
}
