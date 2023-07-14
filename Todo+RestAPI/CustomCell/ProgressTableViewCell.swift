//
//  ProgressTableViewCell.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/21.
//

import UIKit

class ProgressTableViewCell: UITableViewCell {
    
    @IBOutlet var progressButtons: [UIButton]!
 
    var progressCount: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
