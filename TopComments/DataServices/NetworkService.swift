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
    var wasCanceled = false
    
    func fetchCommentsFrom(_ startId: Int, to endId: Int, completion: @escaping(([Comment]) -> Void)){
        wasCanceled = false
        currentURL = baseURLString + "_start=\(startId)&_end=\(endId)"
        Alamofire.request(currentURL).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let jsonArray = response.result.value as? [[String: Any]] {
                    let comments = ResponseParser().parseComments(response: jsonArray)
                    DispatchQueue.main.async {
                        self.wasCanceled = false
                        completion(comments)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func cancelRequest(completion: @escaping(() -> Void)) {
        wasCanceled = true
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
