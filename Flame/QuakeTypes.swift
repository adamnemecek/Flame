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

struct BSPPlane : BSPLump {
    
    var normal: Vector3
    var distance: Float
    var type: Int
    
    static var dataSize = 20
    
    init?(data: NSData) {
        guard data.length == BSPPlane.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        normal = Vector3(parser.readFloat(), parser.readFloat(), parser.readFloat())
        distance = parser.readFloat()
        type = parser.readLong()
    }
    
}

struct BSPFace : BSPLump {
    
    var planeIndex: Int
    var frontFacing: Bool
    var firstEdgeIndex: Int
    var edgeCount: Int
    var textureIndex: Int
    var lightType: Int
    var baseLightLevel: Int
    var extraLightA: Int
    var extraLightB: Int
    var lightmapIndex: Int
    
    static var dataSize = 20
    
    init?(data: NSData) {
        guard data.length == BSPFace.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        planeIndex = parser.readShort()
        frontFacing = parser.readShort() == 1 ? true : false
        firstEdgeIndex = parser.readLong()
        edgeCount = parser.readShort()
        textureIndex = parser.readShort()
        lightType = parser.readByte()
        baseLightLevel = parser.readByte()
        extraLightA = parser.readByte()
        extraLightB = parser.readByte()
        lightmapIndex = parser.readLong()
        
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
