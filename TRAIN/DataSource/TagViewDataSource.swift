//
//  TagViewDataSource.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/04/05.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxCocoa
import RxSwift

class TagViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [String]

    private var items: Element = []

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = "\(items[indexPath.row])"
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, items in
            if dataSource.items == items { return }
            dataSource.items = items
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
