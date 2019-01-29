//
//  Comment.swift
//  TopComments
//
//  Created by  Oleksandra on 1/26/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import Foundation

struct Comment: Decodable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}
