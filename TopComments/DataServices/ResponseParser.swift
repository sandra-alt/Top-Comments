//
//  ResponseParser.swift
//  TopComments
//
//  Created by  Oleksandra on 1/26/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import Foundation
import Alamofire

class ResponseParser {
    func parseComments(response: [[String: Any]]) -> [Comment] {
        let comments : [Comment] = response.map({ json in
                return Comment(json: json)
        })
        return comments
    }
}
