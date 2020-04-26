//
//  TagViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/24.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class TagViewController: UIViewController {
    // おすすめタグを表示するコレクションビュー
    @IBOutlet weak var recommendedCollectionView: UICollectionView! {
        didSet {
            recommendedCollectionView.delegate = self
            recommendedCollectionView.dataSource = self
        }
    }

    // タグを保存するボタン
    @IBOutlet weak var tagAddButton: UIBarButtonItem!
    // TableViewの高さ
    @IBOutlet weak var incrementTableViewHeight: NSLayoutConstraint!
    // CollectionViewの高さ
    @IBOutlet weak var recommendedCollectionViewHeight: NSLayoutConstraint!
    // AddTagViewの高さ
    @IBOutlet weak var addTagViewHeight: NSLayoutConstraint!
    // 選択されたタグの画面
    @IBOutlet weak var addTagView: UIView!
    // インクリメンタルサーチのためのTableView
    @IBOutlet weak var incrementSearchTableView: UITableView! {
        didSet {
            incrementSearchTableView.isHidden = true
            incrementSearchTableView.delegate = self
        }
    }

    // タグを検索するサーチバー
    @IBOutlet weak var tagSearchBar: UISearchBar! {
        didSet {
            tagSearchBar.delegate = self
        }
    }

    private var changeFlg = true
    private var viewFrameHeight: CGFloat?
    private let dataSource = TagViewDataSource()
    private var addTagViewController: AddTagViewController?
    private let disposeBag = DisposeBag()
    // とりあえず固定値
    private var items = ["スイーツ", "パン", "スイーツ", "カフェ", "金沢", "駅前寿司",
                         "祇園", "嵐山", "天満", "七本槍", "鶴橋", "灘", "篠山",
                         "長浜ラーメン", "彦根", "奈良町", "ひがし茶屋街", "尾道",
                         "ランチ", "おばんざい", "寿司", "焼肉", "カレー", "パスタ",
                         "お好み焼き", "越前そば", "チョコレート", "手みやげ", "和雑貨",
                         "文具", "本屋", "酒蔵", "パワースポット", "城下町",
                         "庭園", "アート", "フォトジェニック", "絶景"]
    private let incrementItems = ["A", "B", "C", "a", "b", "c",
                                  "祇園", "嵐山", "天満", "七本槍", "鶴橋", "灘", "篠山",
                                  "長浜ラーメン", "彦根", "奈良町", "ひがし茶屋街", "尾道",
                                  "ランチ", "おばんざい", "寿司", "焼肉", "カレー", "パスタ",
                                  "お好み焼き", "越前そば", "チョコレート", "手みやげ", "和雑貨",
                                  "文具", "本屋", "酒蔵", "パワースポット", "城下町",
                                  "庭園", "アート", "フォトジェニック", "絶景"]

    // インクリメンタルサーチするための検索ワード
    private var incrementalText: Driver<String> {
        rx
            .methodInvoked(#selector(UISearchBarDelegate.searchBar(_:shouldChangeTextIn:replacementText:)))
            .debounce(.microseconds(100), scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<String> in .just(self?.tagSearchBar.text ?? "") }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // インクリメンタルサーチとTableViewの紐付け
        incrementalText
            .flatMap { [weak self] text -> Driver<[String]> in
                guard let me = self else { return .just([]) }
                return .just(me.incrementItems.filter { $0.contains(text.lowercased()) })
            }
            .drive(incrementSearchTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // collectionViewのレイアウトセット
        collectionViewSetUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let tags = UserDefaults.standard.value(forKey: "Tag") as? [String] {
            tagAddButton.isEnabled = true
            addTagViewHeight.constant = recommendedCollectionView.frame.height / 3.5
            recommendedCollectionViewHeight.constant = recommendedCollectionViewHeight.constant - addTagViewHeight.constant
            incrementTableViewHeight.constant = incrementTableViewHeight.constant - addTagViewHeight.constant / 3.5
            changeFlg = false
            addTagViewController?.addTagItem = tags
            addTagViewController?.addTagItemCollectionView.reloadData()
            tagAddButton.isEnabled = true
        } else {
            tagAddButton.isEnabled = false
        }
    }

    func collectionViewSetUp() {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        recommendedCollectionView.collectionViewLayout = layout
    }

    // addTagViewControllerの必要な値を設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext" {
            addTagViewController = segue.destination as? AddTagViewController
            addTagViewController!.incrementTableView = incrementTableViewHeight.constant
            addTagViewController!.recommendedCollectionView = recommendedCollectionViewHeight.constant
            addTagViewController!.tagViewHeight = addTagViewHeight.constant
            addTagViewController!.tagViewController = self
            viewFrameHeight = view.frame.height / 25
            addTagViewController!.viewFrameHeight = viewFrameHeight
        }
    }

    // keyboardの監視
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // keyboard出現
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification, object: nil).subscribe(onNext: { [weak self] _ in
            self?.incrementSearchTableView.isHidden = false
            self?.recommendedCollectionView.isHidden = true
        }).disposed(by: disposeBag)

        // keyboard閉じる
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification, object: nil).subscribe(onNext: { [weak self] _ in
            self?.incrementSearchTableView.isHidden = true
            self?.recommendedCollectionView.isHidden = false
        }).disposed(by: disposeBag)
    }

    @IBAction func tagAdd(_ sender: Any) {
        // タグを保存
        UserDefaults.standard.set(addTagViewController?.addTagItem, forKey: "Tag")
        navigationController?.popViewController(animated: true)
    }
}

extension TagViewController: UICollectionViewDelegateFlowLayout {
    // セクションヘッダのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize.zero
    }

    // セルのサイズ
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = items[indexPath.row]
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.sizeToFit()
        let size = label.frame.size
        return CGSize(width: size.width + 30, height: viewFrameHeight!)
    }
}

extension TagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        cell.label.text = items[indexPath.row]
        cell.layer.masksToBounds = true
        cell.label.sizeToFit()
        cell.layer.cornerRadius = 10

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if changeFlg || addTagViewController?.addTagItem == [] {
            addTagViewHeight.constant = recommendedCollectionView.frame.height / 3.5
            recommendedCollectionViewHeight.constant = recommendedCollectionViewHeight.constant - addTagViewHeight.constant
            incrementTableViewHeight.constant = incrementTableViewHeight.constant - addTagViewHeight.constant / 3.5
            changeFlg = false
        }

        if (addTagViewController?.addTagItem.count)! < 10 {
            let item = items[indexPath.row] + " ✖︎"
            addTagViewController?.addTagItem.append(item)
            tagAddButton.isEnabled = true
            addTagViewController!.text = "選択されたタグ"
            addTagViewController?.addTagItem = addTagViewController?.addTagItem.reduce([]) { $0.contains($1) ? $0 : $0 + [$1] }
            addTagViewController!.addTagItemCollectionView.reloadData()
        }
    }
}

extension TagViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            if changeFlg || addTagViewController?.addTagItem == [] {
                addTagViewHeight.constant = recommendedCollectionView.frame.height / 3.5
                recommendedCollectionViewHeight.constant = recommendedCollectionViewHeight.constant - addTagViewHeight.constant
                incrementTableViewHeight.constant = incrementTableViewHeight.constant - addTagViewHeight.constant / 3.5
                changeFlg = false
            }

            if (addTagViewController?.addTagItem.count)! < 10 {
                addTagViewController?.addTagItem.append(searchBar.text! + " ✖︎")
                tagAddButton.isEnabled = true
                addTagViewController?.addTagItem = addTagViewController?.addTagItem.reduce([]) { $0.contains($1) ? $0 : $0 + [$1] }
                addTagViewController!.addTagItemCollectionView.reloadData()
            }
        }
        tagSearchBar.resignFirstResponder()
        searchBar.text = ""
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        true
    }
}

extension TagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.textLabel?.text != "" {
            if changeFlg {
                addTagViewHeight.constant = recommendedCollectionView.frame.height / 3.5
                recommendedCollectionViewHeight.constant = recommendedCollectionViewHeight.constant - addTagViewHeight.constant
                incrementTableViewHeight.constant = incrementTableViewHeight.constant - addTagViewHeight.constant / 3.5
                changeFlg = false
            }
            addTagViewController?.addTagItem.append((tableView.cellForRow(at: indexPath)?.textLabel?.text)! + " ✖︎")
            addTagViewController!.text = "選択されたタグ"
            addTagViewController?.addTagItem = addTagViewController?.addTagItem.reduce([]) { $0.contains($1) ? $0 : $0 + [$1] }
            tagAddButton.isEnabled = false
            addTagViewController!.addTagItemCollectionView.reloadData()
            tableView.cellForRow(at: indexPath)?.textLabel?.text = ""
            tableView.isHidden = true
            tableView.deselectRow(at: indexPath, animated: true)
            recommendedCollectionView.isHidden = false
            tagSearchBar.text = ""
            tagSearchBar.resignFirstResponder()
        }
    }
}

extension Reactive where Base: UISearchBar {
    var incrementalText: ControlProperty<String?> {
        let delegates: Observable<Void> = Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> Observable<Void> in
            guard let searchBar = searchBar,
                let owner = searchBar.delegate as? UIViewController else { return .empty() }

            let shouldChange = owner.rx
                .methodInvoked(#selector(UISearchBarDelegate.searchBar(_:shouldChangeTextIn:replacementText:)))
                .map { _ in () }

            return Observable
                .of(shouldChange, searchBar.rx.text.map { _ in () }.asObservable())
                .merge()
        }

        let source = delegates
            .debounce(.microseconds(200), scheduler: MainScheduler.instance)
            .flatMap { [weak self = self.base as UISearchBar] _ -> Observable<String?> in .just(self?.text) }
            .distinctUntilChanged { $0 == $1 }

        let bindingObserver = Binder(base) { (searchBar, text: String?) in
            searchBar.text = text
        }

        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
