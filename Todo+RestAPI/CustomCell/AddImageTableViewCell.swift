//
//  AddImageTableViewCell.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/21.
//

import UIKit

class AddImageTableViewCell: UITableViewCell {

    @IBOutlet weak var addedImage: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    
}
