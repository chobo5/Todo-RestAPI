//
//  URLRequest+Ext.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/01/26.
//

import Foundation

extension URLRequest {
  
  private func percentEscapeString(_ string: String) -> String {
    var characterSet = CharacterSet.alphanumerics
    characterSet.insert(charactersIn: "-._* ")
    
    return string
      .addingPercentEncoding(withAllowedCharacters: characterSet)!
      .replacingOccurrences(of: " ", with: "+")
      .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
  }
  
  mutating func percentEncodeParameters(parameters: [String : String]) {
    
      let parameterArray: [String] = parameters.map { (arg) -> String in
      let (key, value) = arg
      return "\(key)=\(self.percentEscapeString(value))"
    }
    
    httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
      // 안에있는 요소들을 묶을때 &로 묶은후 데이터로 인코딩한다.
  }
}
