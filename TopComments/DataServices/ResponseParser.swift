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
    func parseComments(response: DataResponse<Data>) -> [Comment]? {
        guard let data = response.result.value,
            let comments = try? JSONDecoder().decode([Comment].self, from: data) else {
                return nil
        }
        return comments
    }
}
