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
        layout.itemSize = CGSize(width: cellWidth, height: collectionView.frame.height / 3)
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
    private var imageManager = PHCachingImageManager()
    private var fetchResult: PHFetchResult<PHAsset>?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "CameraRollFirstCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CameraRollFirstCollectionViewCell")
        // 選択したイメージの購読
        selectedPhoto.subscribe(onNext: { [weak self] photo in
            DispatchQueue.main.async {
                // 画面を描画する
                self?.updateUI(with: photo)
            }
        }).disposed(by: disposeBag)
        // 決定ボタンのアクション
        decisionButton.rx.tap.subscribe { _ in
            guard let image = self.imageView.image else { return }
            self.currentPhotoSubject.onNext(image)
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        // photoLibraryからPHAssetを取得する
        loadPhotes()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = initViewLayout
    }

    private func updateUI(with image: UIImage?) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
    }

    private func loadPhotes() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                // 許可された場合のみ読み込み開始
                // データの並べ替え条件を作成日時順に設定する
                let options = PHFetchOptions()
                options.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                self.fetchResult = PHAsset.fetchAssets(with: .image, options: options)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }

                // 最新の画像をimageViewに設定してあげる
                let requestOption = PHImageRequestOptions()
                requestOption.deliveryMode = .highQualityFormat
                guard let fetchResult = self.fetchResult else {
                    return
                }
                let photoAsset = fetchResult.object(at: 0)
                self.imageManager.requestImage(for: photoAsset, targetSize: CGSize(width: 480, height: 480), contentMode: .aspectFill, options: requestOption) { image, _ in
                    self.selectedPhotoSubject.onNext(image)
                }

            } else if status == .denied {
                // 投稿画面に戻る
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// collectionViewの設定
extension CameraRollCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetchResult = fetchResult else {
            return 0
        }
        return fetchResult.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0, indexPath.section == 0, indexPath.row == 0 {
            // cellの一番目はカメラの画像に設定する
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraRollFirstCollectionViewCell", for: indexPath) as? CameraRollFirstCollectionViewCell else {
                return UICollectionViewCell()
            }
            // 初期化
            cell.imageView.image = nil
            cell.imageView.image = UIImage(named: "camera.png")
            cell.imageView.contentMode = .scaleAspectFill

            return cell

        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraRollCollectionViewCell", for: indexPath) as? CameraRollCollectionViewCell else {
                return UICollectionViewCell()
            }
            guard let fetchResult = fetchResult else {
                return cell
            }

            if let requestId = cell.requestId {
                imageManager.cancelImageRequest(requestId)
            }
            cell.imageView.image = nil
            let assetIndexPath = indexPath.row - 1
            let photoAsset = fetchResult.object(at: assetIndexPath)

            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            option.isSynchronous = true
            // 画像取得
            cell.requestId = imageManager.requestImage(for: photoAsset, targetSize: CGSize(width: 480, height: 480), contentMode: .aspectFill, options: option, resultHandler: { image, _ in

                DispatchQueue.main.async {
                    cell.imageView.image = image
                    cell.imageView.contentMode = .scaleAspectFill
                }

            })
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // 撮影画面に遷移
            let storyBoard = UIStoryboard(name: "CameraViewController", bundle: nil)
            guard let nxViewController = storyBoard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController else { return }
            nxViewController.currentPhotoSubject = currentPhotoSubject
            navigationController?.pushViewController(nxViewController, animated: true)

        } else {
            guard fetchResult!.count >= indexPath.item else {
                return
            }
            // 画像選択処理
            let photoAsset = fetchResult!.object(at: indexPath.item - 1)
            let requestOption = PHImageRequestOptions()
            requestOption.deliveryMode = .highQualityFormat
//            let selectedAssets = images[indexPath.item - 1]
            imageManager.requestImage(for: photoAsset, targetSize: CGSize(width: 480, height: 480), contentMode: .aspectFill, options: requestOption) { image, _ in
                self.selectedPhotoSubject.onNext(image)
            }
        }
    }
}

extension CameraRollCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            self.imageManager.startCachingImages(for: indexPaths.map { self.fetchResult!.object(at: $0.item - 1) }, targetSize: CGSize(width: 480, height: 480), contentMode: .aspectFill, options: option)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            self.imageManager.stopCachingImages(for: indexPaths.map { self.fetchResult!.object(at: $0.item - 1) }, targetSize: CGSize(width: 480, height: 480), contentMode: .aspectFill, options: option)
        }
    }
}
