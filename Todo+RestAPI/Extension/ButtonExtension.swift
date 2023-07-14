//
//  ButtonExtension.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/13.
//

import Foundation
import UIKit

extension UIButton {
    
    func setGradiant(color1: UIColor, color2: UIColor, color3: UIColor, color4: UIColor) {
        let gradiant : CAGradientLayer = CAGradientLayer()
        gradiant.colors = [color1.cgColor, color2.cgColor, color3.cgColor, color2.cgColor]
        gradiant.locations = [0.0, 1.0]
        gradiant.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradiant.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradiant.frame = bounds
        layer.addSublayer(gradiant)
    }
}
