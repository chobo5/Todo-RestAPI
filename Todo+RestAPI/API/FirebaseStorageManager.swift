//
//  FirebaseStorageManager.swift
//  Todo+RestAPI
//
//  Created by 원준연 on 2023/03/20.
//

import UIKit
import Firebase
import FirebaseStorage

class FirebaseStorageManager {
    
    enum imageError: Error {
        case wrongImageURL
        
    }
    
    static func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let imageName = String(Date().timeIntervalSince1970)
        
        let firebaseReference = Storage.storage().reference().child("\(imageName)")
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            firebaseReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    static func downloadImage(urlString: String, completion: @escaping (Result<UIImage?, imageError>) -> Void) {
        let storageReference = Storage.storage().reference(forURL: urlString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        storageReference.getData(maxSize: megaByte) { data, error in
            if let imageData = data{
                completion(.success(UIImage(data: imageData)))
            } else {
                completion(.failure(imageError.wrongImageURL))
            }
            
        }
    }
    
}
