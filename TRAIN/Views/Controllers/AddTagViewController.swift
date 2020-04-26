//
//  AddTagViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/04/08.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import UIKit

class AddTagViewController: UIViewController {
    var addTagItem: [String]!

    @IBOutlet weak var addTagItemCollectionView: UICollectionView! {
        didSet {
            addTagItemCollectionView.delegate = self
            addTagItemCollectionView.dataSource = self
        }
    }

    var text: String?
    var incrementTableView: CGFloat?
    var recommendedCollectionView: CGFloat?
    var tagViewHeight: CGFloat?
    var tagViewController: TagViewController?
    var viewFrameHeight: CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        text = String()
        addTagItem = []
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        addTagItemCollectionView.collectionViewLayout = layout
    }
}

extension AddTagViewController: UICollectionViewDelegateFlowLayout {
    // セクションヘッダのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize.zero
    }

    // セルのサイズ
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = addTagItem?[indexPath.row]
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.sizeToFit()
        let size = label.frame.size
        return CGSize(width: size.width + 30, height: viewFrameHeight!)
    }
}

extension AddTagViewController: UICollectionViewDelegate {}

extension AddTagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        addTagItem?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTagViewCell", for: indexPath)
        cell.layer.cornerRadius = 10
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.text = addTagItem![indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addTagItem.remove(at: indexPath.row)
        collectionView.reloadData()
        if addTagItem == [] {
            tagViewController?.addTagViewHeight.constant = tagViewHeight!
            tagViewController?.incrementTableViewHeight.constant = incrementTableView!
            tagViewController?.recommendedCollectionViewHeight.constant = recommendedCollectionView!
        }
    }
}

extension Array where Element: Hashable {
    func addUnique(array: Array) -> Array {
        let dict = Dictionary(map { ($0, 1) }, uniquingKeysWith: +)
        return self + array.filter { dict[$0] == nil }
    }
}
