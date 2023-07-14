//
//  Delegate.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/03/20.
//

import Foundation
import UIKit

protocol sendTodoDelegate: AnyObject {
    func sendNewTodo(todo: Todo)
    func sendUpdatedTodo(todo: Todo)
    func sendImageOnly(image: UIImage?)
}
