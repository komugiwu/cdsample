//
//  TaskTableViewCell.swift
//  coredatasample
//
//  Created by ITI on 2017/05/24.
//  Copyright © 2017年 Masami Suzuki. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    static let reuseIdentifier = "TaskCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
