//
//  TodosAPI.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/26.
//


import Foundation


enum TodosAPI {
    
    static let version = "v1"
#if DEBUG //전처리기 - compile이 되기전에 실행된다(Debug용)
    static let baseURL = "https://port-0-container-1ih8d2gld1q6ldo.gksl2.cloudtype.app/api/" + version
    //Product -> Scheme -> EditScheme에서 Debug용으로 하느냐 Release용으로 하느냐에따라 baseURL을 변경할 수 있다.
    
#else //(Release용)
    static let baseURL = "https://port-0-container-1ih8d2gld1q6ldo.gksl2.cloudtype.app/api/" + version
    
#endif
    enum ApiError: Error {
        case noContentError
        case decodingError
        case jsonEncoding
        case unAuthorized
        case notFound
        case Forbidden
        case notAllowedURL
        case badStatus(code: Int) //우리가 모르는 에러인데 이것에 대한 코드만 에러타입으로 내보낸다.
        case unknownError(_ err: Error?)
        
        var info: String {
            switch self {
            case .noContentError:           return "데이터가 없습니다."
            case .decodingError:            return "디코딩 에러"
            case .jsonEncoding:             return "유요한 json형식이 아닙니다."
            case .unAuthorized:             return "인증되지 않은 사용자입니다."
            case .notFound:                 return "찾을수 없습니다."
            case .Forbidden:                return "접근이 금지되었습니다."
            case .notAllowedURL:            return "올바른 URL형식이 아닙니다."
            case let .badStatus(code):      return "에러 상태코드: \(code)"  //enum에서 들어온것이기 때문에 let 해준다
            case .unknownError(let err):    return "알 수 없는 에러: \(err)"
            }
        }
    }
    
    
}

