//
//  Todos.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/26.
//

import Foundation
import UIKit

//MARK: - TodoResponse


// MARK: - Todo
struct Todo: Codable {
    var content: String?
    var id: Int?
    var imageURl: String?
    var modifiedDate: String?
    var progressCount: Int?
    var title: String?
    var colorCount: Int?
    var createdDate : String?
    var isEdited: Bool? = false
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case content ,imageURl,modifiedDate ,title ,createdDate
        case id, progressCount, colorCount
        
    }
}







