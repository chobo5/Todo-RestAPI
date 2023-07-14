//
//  CustomButton.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/21.
//

import Foundation
import UIKit

@IBDesignable // 인터페이스 빌더에서 디자인으로 확인 가능하게끔
class CustomButton: UIButton {
    
    @IBInspectable //인스펙터 패널에서 사용될 수 있도록 설정
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var isCircle : Bool = false {
        didSet{
            if isSquare && isCircle {
                self.layer.cornerRadius = self.frame.width / 2
            }
        }
        
    }
    //뷰 정사각형 여부
    fileprivate var isSquare : Bool {
        get {
            return self.frame.width == self.frame.height
        }
    }
}
