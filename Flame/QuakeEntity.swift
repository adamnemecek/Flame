//
//  QuakeEntity.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 1/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

struct QuakeEntity {
    var className: String
    var origin: Vector3?
    
    var properties: [String: String]
    
    init() {
        className = ""
        properties = [String: String]()
    }
}
