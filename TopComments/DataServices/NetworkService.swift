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
    
    func fetchCommentsFrom(_ startId: Int, to endId: Int, completion: @escaping(([Comment]) -> Void)){
        let url = baseURLString + "_start=\(startId)&_end=\(endId)"
        Alamofire.request(url).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let jsonArray = response.result.value as? [[String: Any]] {
                    let comments = ResponseParser().parseComments(response: jsonArray)
                    DispatchQueue.main.async {
                        completion(comments)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func cancelRequest(completion: @escaping(() -> Void)) {
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach({$0.cancel()})
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    
}
