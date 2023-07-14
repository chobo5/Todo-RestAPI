//
//  ColorExtension.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/12.
//

import Foundation
import UIKit

extension UIColor {
    //lightDark - (0.114, 0.106, 0.125, 100%)
    class var lightDark: UIColor? { return UIColor(named: "lightDark") }
    
    //importanceRed - (0.922, 0.247, 0.388, 100%)
    class var importanceRed: UIColor? { return UIColor(named: "importanceRed") }
    
    //importanceYellow - (0.980, 0.953, 0.318, 100%)
    class var importanceYellow: UIColor? { return UIColor(named: "importanceYellow") }
    
    //importanceBlue - (0.514, 0.671, 0.824, 100%)
    class var importanceBlue: UIColor? { return UIColor(named: "importanceBlue") }
    
    //gradiant1 - (0.475, 0.863, 0.973, 100%)
    class var gradiant1: UIColor? { return UIColor(named: "gradiant1") }
    
    //gradiant2 - (0.518, 0.294, 0.961, 100%)
    class var gradiant2: UIColor? { return UIColor(named: "gradiant2") }
    
    //gradiant3 -
    class var gradiant3: UIColor? { return UIColor(named: "gradiant3") }
    
    //gradiant4 -
    class var gradiant4: UIColor? { return UIColor(named: "gradiant4") }
    
    //deselectedColor -
    class var deselectedColor: UIColor? { return UIColor(named: "deselectedColor") }
}

extension UITextField {
    
    func setPlaceholderColor(_ placeholderColor: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font
            ].compactMapValues { $0 }
        )
    }
    
}


