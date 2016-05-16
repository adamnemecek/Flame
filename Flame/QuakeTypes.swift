//
//  QuakeTypes.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 1/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

enum QuakePlaneType: Int {
    case xAxisAligned = 0
    case yAxisAligned = 1
    case zAxisAligned = 2
    case xAxisApproximate = 3
    case yAxisApproximate = 4
    case zAxisApproximate = 5
}

struct QuakeEntity {
    var className: String
    var origin: Vector3?
    
    var properties: [String: String]
    
    init() {
        className = ""
        properties = [String: String]()
    }
}

struct QuakePlane {
    var normal: Vector3
    var distance: Float
    var type: QuakePlaneType
}

struct QuakeEdge {
    var startVertexIndex: Int
    var endVertexIndex: Int
}
