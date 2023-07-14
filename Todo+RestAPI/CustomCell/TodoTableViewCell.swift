//
//  TodoTableViewCell.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/11.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet var cellView: UIView!
    @IBOutlet weak var importanceColorBar: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet var progressButtons: [UIButton]!
    
    var cellData: Todo? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
    
    
    // Cell 데이터 적용
    func updateUI(_ cellData: Todo) {
        guard let id: Int = cellData.id,
              let title: String = cellData.title,
              let progressCount: Int = cellData.progressCount,
              let importanceColor: Int = cellData.colorCount else {
            print("Todo에 데이터가 없습니다.")
            return
        }
        
        //할일 ID와 제목 설정
        self.titleLabel.text = "ID: \(id) - \(title)"
        
        //할일 진행도(번개모양) 설정 0 - 1개, 1 - 2개, 2 - 3개
        switch progressCount {
        case 0:
            progressButtons[0].tintColor = UIColor.importanceBlue
            progressButtons[1].tintColor = UIColor.deselectedColor
            progressButtons[2].tintColor = UIColor.deselectedColor
        case 1:
            progressButtons[0].tintColor = UIColor.importanceBlue
            progressButtons[1].tintColor = UIColor.importanceBlue
            progressButtons[2].tintColor = UIColor.deselectedColor
        case 2:
            progressButtons[0].tintColor = UIColor.importanceBlue
            progressButtons[1].tintColor = UIColor.importanceBlue
            progressButtons[2].tintColor = UIColor.importanceBlue
        default:
            progressButtons[0].tintColor = UIColor.deselectedColor
            progressButtons[1].tintColor = UIColor.deselectedColor
            progressButtons[2].tintColor = UIColor.deselectedColor
        }
        
        //할일 중요도 설정 0 - 빨강, 1 - 노랑, 2 - 파랑
        switch importanceColor {
        case 0:
            importanceColorBar.backgroundColor = UIColor.importanceRed
        case 1:
            importanceColorBar.backgroundColor = UIColor.importanceYellow
        case 2:
            importanceColorBar.backgroundColor = UIColor.importanceBlue
        default:
            importanceColorBar.backgroundColor = UIColor.white
        }
    }
}
