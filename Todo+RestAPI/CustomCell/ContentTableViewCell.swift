//
//  ContentTableViewCell.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/21.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //텍스트뷰에 padding값을 없애고, 입력값 제한없이 받기
        contentTextView.textContainer.maximumNumberOfLines = 0
        contentTextView.textContainer.lineFragmentPadding = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
