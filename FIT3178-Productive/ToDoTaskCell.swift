//
//  ToDoTaskCell.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 25/5/2022.
//

import UIKit

class ToDoTaskCell: UITableViewCell {


    
    @IBOutlet weak var taskTitleOutlet: UILabel!
    
    @IBOutlet weak var timeLabelOutlet: UILabel!
    @IBOutlet weak var taskDescriptionOutlet: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
