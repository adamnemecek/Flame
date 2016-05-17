//
//  QuakeTypes.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 1/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

protocol BSPLump {
    
    static var dataSize: Int { get set }
    
    init?(data: NSData)
    
}

struct BSPHeaderEntry : BSPLump {
    
    var offset: Int
    var size: Int
    
    static var dataSize = 8
    
    init?(data: NSData) {
        guard data.length == BSPHeaderEntry.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        offset = parser.readLong()
        size = parser.readLong()
    }
    
}

struct BSPEdge : BSPLump {
    
    var startVertexIndex: Int
    var endVertexIndex: Int
    
    static var dataSize = 4
    
    init?(data: NSData) {
        guard data.length == BSPEdge.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        startVertexIndex = parser.readShort()
        endVertexIndex = parser.readShort()
    }
    
}

struct BSPVertex : BSPLump {
    
    var x: Float
    var y: Float
    var z: Float
    
    static var dataSize = 12
    
    init?(data: NSData) {
        guard data.length == BSPVertex.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        x = parser.readFloat()
        y = parser.readFloat()
        z = parser.readFloat()
    }
    
}

struct BSPEntity {
    var className: String
    var origin: Vector3?
    
    var properties: [String: String]
    
    init() {
        className = ""
        properties = [String: String]()
    }
}
