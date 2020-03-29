//
//  CameraRollCollectionViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/22.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Photos
import RxSwift
import UIKit

class CameraRollCollectionViewController: UIViewController {
    // 写真を選択するボタン
    @IBOutlet weak var decisionButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    private let disposeBag = DisposeBag()

    private lazy var initViewLayout: Void = {
        let layout = UICollectionViewFlowLayout()
        // 列の分割列
        let columnsCount = 3
        // CollectionViewの枠とCellの間の隙間
        let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        // Cellの左右のスペースの最小値
        let minimumInteritemSpacing: CGFloat = 0.0
        let minimumLineSpacing: CGFloat = 0.0
        let viewWidth = collectionView.frame.size.width

        // Cellサイズ
        let cellWidth = viewWidth / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.minimumLineSpacing = minimumLineSpacing
        layout.sectionInset = sectionInset
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()

    }()

    // 選択した画像
    private let selectedPhotoSubject = PublishSubject<UIImage?>()
    var selectedPhoto: Observable<UIImage?> {
        selectedPhotoSubject.asObservable()
    }

    // 現在選択されている画像
    private let currentPhotoSubject = PublishSubject<UIImage>()
    var currentPhoto: Observable<UIImage> {
        currentPhotoSubject.asObservable()
    }

    // 取得したPHAssetを格納
    private var images = [PHAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 選択したイメージの購読
        selectedPhoto.subscribe(onNext: { [weak self] photo in
            DispatchQueue.main.async {
                // 画面を描画する
                self?.updateUI(with: photo)
            }
        }).disposed(by: disposeBag)
        // 決定ボタンのアクション
        decisionButton.rx.tap.subscribe { _ in
            self.currentPhotoSubject.onNext(self.imageView.image!)
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        // photoLibraryからPHAssetを取得する
        populerPhotes()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = initViewLayout
    }

    private func updateUI(with image: UIImage?) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
    }

    private func populerPhotes() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in

            if status == .authorized {
                // 許可された場合のみ読み込み開始
                // imageを指定
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                assets.enumerateObjects { object, _, _ in
                    self?.images.append(object)
                }
//                self?.images.reverse()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }

            } else if status == .denied {
                // MARK: 拒否の場合は？
            }
        }
    }
}

// collectionViewの設定
extension CameraRollCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraRollCollectionViewCell", for: indexPath) as? CameraRollCollectionViewCell else {
            return UICollectionViewCell()
        }
        // cellを使い回す前に前のrequestをキャンセルして画像を削除
        let imageManager = PHImageManager.default()
        if let requestId = cell.requestId {
            imageManager.cancelImageRequest(requestId)
        }
//        cell.imageView.image = nil
        // 最初のセルはカメラ撮影遷移画像を差し込む

        // MARK: 二回目の遷移で見えなくなる

        if indexPath.row == 0 {
            cell.imageView.image = UIImage(named: "camera.jpg")
            cell.imageView.contentMode = .scaleAspectFill
        } else {
            let assetIndexPath = indexPath.row - 1
            let asset = images[assetIndexPath]
            cell.requestId = imageManager.requestImage(for: asset, targetSize: CGSize(width: 480, height: 480), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                DispatchQueue.main.async {
                    if assetIndexPath == 0 {
                        self.selectedPhotoSubject.onNext(image)
                    }
                    cell.imageView.image = image
                    cell.imageView.contentMode = .scaleAspectFill
                }
            })
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            selectedPhotoSubject.onNext(UIImage(named: "camera")!)
            // 撮影画面に遷移
            let storyBoard = UIStoryboard(name: "CameraViewController", bundle: nil)
            let nxViewController = storyBoard.instantiateViewController(withIdentifier: "CameraViewController")
            navigationController?.pushViewController(nxViewController, animated: true)

        } else {
            // 画像選択処理
            let selectedAssets = images[indexPath.item - 1]
            PHImageManager.default().requestImage(for: selectedAssets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { [weak self] image, info in
                guard let info = info else { return }
                let isDegradedImage = info["PHImageResultIsDegradedKey"] as! Bool

                if !isDegradedImage {
                    if let image = image {
                        self?.selectedPhotoSubject.onNext(image)
                    }
                }
            }
        }
    }
}
