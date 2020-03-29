//
//  TrainingSetTableViewCell.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/02/28.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxSwift
import UIKit

class TrainingSetTableViewCell: UITableViewCell {
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    var viewModel = TrainingSetTableViewModel()
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // textFieleにアンダーラインを入れる
        countTextField.underlined()
        weightTextField.underlined()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
