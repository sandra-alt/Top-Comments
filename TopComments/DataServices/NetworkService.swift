//
//  NetworkService.swift
//  TopComments
//
//  Created by  Oleksandra on 1/26/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService {
    
    private let baseURLString = "https://jsonplaceholder.typicode.com/comments?"
    private var currentURL = ""
    
    func fetchCommentsFrom(_ startId: Int, to endId: Int, completion: @escaping(([Comment]?) -> Void)){
        currentURL = baseURLString + "_start=\(startId)&_end=\(endId)"
        Alamofire.request(currentURL).validate().responseData { response in
            switch response.result {
            case .success:
                let comments = ResponseParser().parseComments(response: response)
                DispatchQueue.main.async {
                    completion(comments)
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func cancelRequest(completion: @escaping(() -> Void)) {
        Alamofire.SessionManager.default.session.getAllTasks{sessionTasks in
            for task in sessionTasks {
                if task.originalRequest?.url == URL(string: self.currentURL) {
                    task.cancel()
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    
    }
}
