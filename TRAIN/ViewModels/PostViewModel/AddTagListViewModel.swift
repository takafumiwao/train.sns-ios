//
//  AddTagListViewModel.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/07/04.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Foundation

class AddTagListViewModel {
    // MARK: 検索ワード(APIから取るようになる)

    private let incrementItems = ["A", "B", "C", "a", "b", "c",
                                  "祇園", "嵐山", "天満", "七本槍", "鶴橋", "灘", "篠山",
                                  "長浜ラーメン", "彦根", "奈良町", "ひがし茶屋街", "尾道",
                                  "ランチ", "おばんざい", "寿司", "焼肉", "カレー", "パスタ",
                                  "お好み焼き", "越前そば", "チョコレート", "手みやげ", "和雑貨",
                                  "文具", "本屋", "酒蔵", "パワースポット", "城下町",
                                  "庭園", "アート", "フォトジェニック", "絶景"]

    // タグを読み込む
    func loadingTags() -> (selectTagList: [String], incrementItems: [String]) {
        var selectTagList = [String]()
        if let usrTagList = UserDefaults.standard.value(forKey: "Tags") as? [String] {
            selectTagList = usrTagList
        }

        // MARK: APIでおすすめのたぐリストを取得する

        return (selectTagList, incrementItems)
    }

    // タグをセットする
    func settingTags(tags: [String]) {
        UserDefaults.standard.set(tags, forKey: "Tags")
    }
}
