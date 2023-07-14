//
//  TodosAPI+Alamofire.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/03/13.
//

import Foundation
import Alamofire


enum TodosAlamofire {
    
    static let version = "v1"
    
    static let baseURL = "https://port-0-container-1ih8d2gld1q6ldo.gksl2.cloudtype.app/api/" + version
    
    
    static func getTodos() {
        let url = baseURL + "/todos"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseJSON { json in
            print(json)
        }
    }
    
    static func postTodo(title: String,
                         content: String,
                         imageURl: String,
                         progressCount: Int,
                         colorCount: Int) {
        let url = baseURL + "/todo"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let params : [String : Any] = ["title" : title, "content" : content, "imageURL" : imageURl, "progressCount": progressCount, "colorCount" : colorCount]
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("POST 성공")
            case .failure(let error):
                print("error : \(error.errorDescription!)")
            }
        }
        
    }
    
    static func deleteATodo(id: Int) {
        let url = baseURL + "/todo/\(id)"
        AF.request(url,
                   method: .delete,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .responseJSON { json in
            print(json)
        }
    }
    
    static func updateATodo(id: Int,
                            title: String,
                            content: String,
                            imageURl: String,
                            progressCount: Int,
                            colorCount: Int) {
        let url = baseURL + "/todo" + "/\(id)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let params : [String : Any] = ["title" : title, "content" : content, "imageURL" : imageURl, "progressCount": progressCount, "colorCount" : colorCount]
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        AF.request(request).responseString { (response) in
            switch response.result {
            case .success:
                print("update 성공")
            case .failure(let error):
                print("error : \(error.errorDescription!)")
            }
        }
    }
}
