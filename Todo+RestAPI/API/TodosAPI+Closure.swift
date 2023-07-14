//
//  TodosAPI+Closure.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/26.
//

import Foundation


extension TodosAPI {
    
    //MARK: - 모든 할 일 가져오기(Closure기반의 fetch)
    static func fetchTodos(completion: @escaping (Result<[Todo], ApiError>) -> Void) {
        //단순히 클로저 내부에서 끝나는 것이 아니라 받아온 data를 처리하기위해 클로저 밖으로 보내야 하므로 @escaping키워드를 사용
        //성공, 실패에 대한 처리를 위해 Result enum을 사용한다. Result<Success, Failure> 형태
        
        //1. urlRequest를 만든다.
        let urlString = baseURL + "/todos"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "accept")
        
        //2. urlSession으로 API를 호출한다. 3. API 호출에 대한 응답을 받는다.
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
//            print("data: \(data)")
//            print("urlResponse: \(urlResponse)")
//            print("error: \(err)")
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    let todos = try JSONDecoder().decode([Todo].self, from: jsonData)
                    //기존의 정대리swagger와 다르게 배열안에 바로 할일이 있는 형태이며, 할일 이외에 들어오는 message나 response가 없기 때문에 바로 배열로 받아 처리합니다.
                    let modelObjects = todos
//                    print("todos: \(todos)")
                    completion(.success(todos))
                    
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                    //jsonData처리 중 발생한 에러이기 때문에 필연적으로 decodingError입니다.
                }
            }
            
        }.resume()
    }
    
    //MARK: - 할 일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답 결과
    
    static func deleteATodo(id: Int, completion: @escaping(Result<Todo, ApiError>) -> Void) {
        
        print(#fileID, #function, #line, "- deleteSelectedTodos호출됨 - /id: \(id)")
        
        //1. urlRequest를 만든다.
        let urlString = baseURL + "/todo/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "accept")
        
        //2. urlSession으로 API를 호출한다. 3. API 호출에 대한 응답을 받는다.
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
//            print("data: \(data)")
//            print("urlRespons: \(urlResponse)")
//            print("error: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
            // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                
                print("bad status code")
                return completion(.failure(ApiError.unknownError(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unAuthorized))
            case 403:
                return completion(.failure(ApiError.Forbidden))
            case 204:
                return completion(.failure(ApiError.noContentError))
            default:
                print("default")
            }
            
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            //JSON -> Struct로 변경, 즉 Decoding, 데이터 파싱
            if let jsonData = data {
                // convert data to our swift model
                print(String(data: jsonData, encoding: .utf8))
            }
        }.resume() 
        
    }
    
    
    //MARK: - 할 일 추가하기 - POST
    /// - Parameters:
    ///   - title: 제목
    ///   - content: 내용
    ///   - imageURl: imageURL
    ///   - progressCount: 진행도(0 , 1, 2)
    ///   - colorCount: 중요도(1- red, 2 - yellow, 3 - blue)
    ///   - completion: 응답결과
    static func addATodo(title: String,
                         content: String,
                         imageURl: String,
                         progressCount: Int,
                         colorCount: Int,
                         completion: @escaping (Result<Todo, ApiError>) -> Void) {
        
        //1. urlRequest를 만든다.
        let urlString = baseURL + "/todo"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["title" : title, "content" : content, "imageURl" : imageURl, "progressCount": progressCount, "colorCount" : colorCount]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.jsonEncoding))
        }
        
        //2. urlSession으로 API를 호출한다. 3. API 호출에 대한 응답을 받는다.
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
            print("error: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
            // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknownError(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unAuthorized))
            case 403:
                return completion(.failure(ApiError.Forbidden))
            case 404:
                return completion(.failure(ApiError.notFound))
            default:
                print("default")
            }
            
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            //JSON -> Struct로 변경, 즉 Decoding, 데이터 파싱
            if let jsonData = data {
                // convert data to our swift model
                do {
                    let baseResponse = try JSONDecoder().decode(Todo.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
    
    //MARK: - 할 일 수정하기 - PUT
    /// - Parameters:
    ///   - title: 제목
    ///   - content: 내용
    ///   - imageURl: imageURL
    ///   - progressCount: 진행도(0 , 1, 2)
    ///   - colorCount: 중요도(1- red, 2 - yellow, 3 - blue)
    ///   - completion: 응답결과
    static func updateATodo(id: Int,
                         title: String,
                         content: String,
                         imageURl: String,
                         progressCount: Int,
                         colorCount: Int,
                         completion: @escaping (Result<Int?, ApiError>) -> Void) {
        
        //1. urlRequest를 만든다.
        let urlString = baseURL + "/todo" + "/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        let requestParams : [String : Any] = ["id" : id, "title" : title, "content" : content, "imageURl" : imageURl, "progressCount": progressCount, "colorCount" : colorCount]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.jsonEncoding))
        }
        
        //2. urlSession으로 API를 호출한다. 3. API 호출에 대한 응답을 받는다.
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("updatedData: \(data)")
            print("urlResponse: \(urlResponse)")
            print("error: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
            // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknownError(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unAuthorized))
            case 403:
                return completion(.failure(ApiError.Forbidden))
            case 404:
                return completion(.failure(ApiError.notFound))
            default:
                print("default")
            }
            
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            //JSON -> Struct로 변경, 즉 Decoding, 데이터 파싱
            if let jsonData = data {
                // convert data to our swift model
                do {
                    let baseResponse = try JSONDecoder().decode(Int.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }

    //MARK: - 할 일 가져오기 - GET
    /// - Parameters:
    ///   - id: 가져올 아이템 아이디
    ///   - completion: 응답 결과
    
    static func getATodo(id: Int, completion: @escaping(Result<Todo, ApiError>) -> Void) {
        
        print(#fileID, #function, #line, "- getATodo호출됨 - /id: \(id)")
        
        //1. urlRequest를 만든다.
        let urlString = baseURL + "/todo/\(id)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedURL))
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "accept")
        
        
        //2. urlSession으로 API를 호출한다. 3. API 호출에 대한 응답을 받는다.
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            print("data: \(data)")
            print("urlResponse: \(urlResponse)")
            print("error: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknownError(error)))
            }
            
            // first we have to type cast URLResponse to HTTPURLRepsonse to get access to the status code
            // we verify the that status code is in the 200 range which signals all went well with the GET request
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknownError(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unAuthorized))
            case 403:
                return completion(.failure(ApiError.Forbidden))
            case 404:
                return completion(.failure(ApiError.notFound))
            default:
                print("default")
            }
            
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            //JSON -> Struct로 변경, 즉 Decoding, 데이터 파싱
            if let jsonData = data {
                // convert data to our swift model
                do {
                    let baseResponse = try JSONDecoder().decode(Todo.self, from: jsonData)
                    
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
        }.resume()
    }
}
