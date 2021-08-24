//
//  ExpenseTableViewCell.swift
//  ExpenseTracker2
//
//  Created by curry敏 on 2021/8/11.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var cellimage: UIImageView!
    @IBOutlet weak var cellExpense: UILabel!
    @IBOutlet weak var cellView: ViewModel!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellimage.layer.cornerRadius = cellimage.layer.frame.height / 2
        cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
