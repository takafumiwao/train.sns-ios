//
//  AddTagListViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/06/02.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift
import TagListView
import UIKit

class AddTagListViewController: UIViewController, TagListViewDelegate, UINavigationControllerDelegate {
    private let disposeBag = DisposeBag()
    private let addTagListViewModel = AddTagListViewModel()
    private var showSearchWords = [String]()
    private let margin: CGFloat = 10
    private let tagListView = TagListView()
    private let recommendedTagListView = TagListView()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var incrementItems = [String]()
    private var navFrame: CGRect = CGRect()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navigationController = navigationController else {
            return
        }

        navigationController.delegate = self
        let navBarFrame = navigationController.navigationBar.frame
        navFrame = navBarFrame
        setView()

        setupIncrementSearch()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tableView.isHidden = true
        view.endEditing(true)
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let apVC = viewController as? PostArticleViewController else { return }

        var tags = [String]()

        tagListView.tagViews.forEach { tagView in
            guard let text = tagView.titleLabel?.text else { return }
            tags.append(text)
        }

        addTagListViewModel.settingTags(tags: tags)
        apVC.settingParts()
    }

    private func setView() {
        view.addSubview(tagListView)
        view.addSubview(searchBar)
        view.addSubview(recommendedTagListView)
        view.addSubview(tableView)

        tagListView.frame = CGRect(x: margin, y: navFrame.height + navFrame.origin.y + margin, width: view.frame.width - (margin * 2), height: 0)
        tagListView.enableRemoveButton = true
        tagListView.delegate = self
        tagListView.tag = 1
        tagListView.alignment = .left
        tagListView.cornerRadius = 3
        tagListView.textColor = .black
        tagListView.borderColor = UIColor.lightGray
        tagListView.borderWidth = 1
        tagListView.paddingX = 10
        tagListView.paddingY = 5
        tagListView.textFont = UIFont.systemFont(ofSize: 16)
        tagListView.tagBackgroundColor = .white
        tagListView.removeButtonIconSize = 10
        tagListView.removeIconLineColor = .black

        searchBar.frame = CGRect(x: margin, y: tagListView.frame.origin.y + tagListView.frame.height + 5, width: view.frame.width - (margin * 2), height: 40)
        searchBar.delegate = self
        searchBar.placeholder = "タグを入力してください"
        searchBar.returnKeyType = .done
        // searchBarの上下の線を消す
        searchBar.backgroundImage = UIImage()

        recommendedTagListView.frame = CGRect(x: margin, y: searchBar.frame.origin.y + searchBar.frame.height + 5, width: view.frame.width - (margin * 2), height: 0)
        recommendedTagListView.enableRemoveButton = false
        recommendedTagListView.delegate = self
        recommendedTagListView.tag = 2
        recommendedTagListView.alignment = .left
        recommendedTagListView.cornerRadius = 3
        recommendedTagListView.textColor = .black
        recommendedTagListView.borderColor = .lightGray
        recommendedTagListView.borderWidth = 1
        recommendedTagListView.paddingX = 10
        recommendedTagListView.paddingY = 5
        recommendedTagListView.textFont = .systemFont(ofSize: 16)
        recommendedTagListView.tagBackgroundColor = .white
        recommendedTagListView.removeButtonIconSize = 10
        recommendedTagListView.removeIconLineColor = .black

        tableView.frame = CGRect(x: margin, y: searchBar.frame.origin.y + searchBar.frame.height, width: view.frame.width - (margin * 2), height: view.bounds.height / 5)
        tableView.isHidden = true

        // タグを取得する
        getTags()
        // レイアウト調整
        updateLayout()
    }

    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 1 {
            // タグ削除ボタンが押されたらリストからタグを削除
            sender.removeTagView(tagView)
        }
        updateLayout()
    }

    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if sender.tag == 2 {
            var texts = [String]()
            tagListView.tagViews.forEach { tagView in
                guard let text = tagView.titleLabel?.text else { return }
                texts.append(text)
            }

            guard let targetText = tagView.titleLabel?.text else { return }
            // 選択数が10以上ならば追加しない,選択タグリストにすでに存在していたら追加しない,
            if !(tagListView.tagViews.count >= 10), !texts.contains(targetText) {
                tagListView.addTag(targetText)
            }
        }

        updateLayout()
    }

    private func updateLayout() {
        // タグ全体の高さを取得
        tagListView.frame.size.height = tagListView.intrinsicContentSize.height
        // searchBarのレイアウト更新
        searchBar.frame.origin.y = tagListView.frame.origin.y + tagListView.frame.height + 5
        // tableViewのレイアウト更新
        tableView.frame.origin.y = searchBar.frame.origin.y + searchBar.frame.height
        // おすすめタグのレイアウト更新
        recommendedTagListView.frame.size.height = recommendedTagListView.intrinsicContentSize.height
        recommendedTagListView.frame.origin.y = searchBar.frame.origin.y + searchBar.frame.height + 5
    }

    private func getTags() {
        // タグを読み込む
        let loadingTags = addTagListViewModel.loadingTags()

        loadingTags.selectTagList.forEach { string in
            tagListView.addTag(string)
        }

        loadingTags.incrementItems.forEach { string in
            recommendedTagListView.addTag(string)
        }
        incrementItems = loadingTags.incrementItems
    }
}

private extension AddTagListViewController {
    private func setupIncrementSearch() {
        showSearchWords = incrementItems
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        let debounceInterval = RxTimeInterval.microseconds(3)

        // インクリメンタルサーチのテキストを取得するためのObservable
        let incrementalSearchTextObservable = rx
            // UISearchBarに文字列入力中に呼ばれるUISearchBarDelegateのメソッドをフック
            .methodInvoked(#selector(UISearchBarDelegate.searchBar(_:shouldChangeTextIn:replacementText:)))
            // searchBar.textの値が確定するまで0.3待つ
            .debounce(debounceInterval, scheduler: MainScheduler.instance)
            // 確定したsearchBar.textを取得
            .flatMap { [unowned self] _ in Observable.just(self.searchBar.text ?? "") }

        // UISearchBarのクリアボタンや確定ボタンタップにテキストを取得するためのObservable
        let textObservable = searchBar.rx.text.orEmpty.asObservable()

        // 2つのObservableをマージ
        let searchTextObservable = Observable.merge(incrementalSearchTextObservable, textObservable)
            // 初期化時にカラ文字が流れてくるので無視
            .skip(1)
            // 0.3秒経過したら入力確定とみなす
            .debounce(debounceInterval, scheduler: MainScheduler.instance)
            // 変化があるまで文字列が流れないようにする、つまり連続して同じテキストで検索しないようにする
            .distinctUntilChanged()

        // subscribeして流れてくるテキストを使用して検索
        searchTextObservable.subscribe(onNext: { [weak self] text in

            guard let self = self else {
                return
            }
            if text.isEmpty {
                // カラ文字の場合はTableViewを隠す
                self.tableView.isHidden = true
                self.showSearchWords = []
            } else {
                // 入力文字がある場合はデータをフィルタリングして表示
                self.showSearchWords = self.incrementItems.filter { $0.contains(text) }
                if self.showSearchWords.count >= 1 {
                    self.tableView.isHidden = false
                }
            }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension AddTagListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showSearchWords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = showSearchWords[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = showSearchWords[indexPath.row]
        // タグの選択数が10以上でないか、重複していないかチェック
        var texts = [String]()
        tagListView.tagViews.forEach { tagView in
            guard let text = tagView.titleLabel?.text else { return }
            texts.append(text)
        }
        if !(tagListView.tagViews.count >= 10), !texts.contains(tag) {
            tagListView.addTag(tag)
        }
        updateLayout()
        searchBar.text = ""
        tableView.isHidden = true
    }
}

extension AddTagListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        // タグの選択数が10以上でないか、重複していないかチェック
        var texts = [String]()
        tagListView.tagViews.forEach { tagView in
            guard let text = tagView.titleLabel?.text else { return }
            texts.append(text)
        }
        if !(tagListView.tagViews.count >= 10), !texts.contains(searchBarText) {
            tagListView.addTag(searchBarText)
        }
        updateLayout()
        searchBar.text = ""
        tableView.isHidden = true
        searchBar.resignFirstResponder()
    }
}
