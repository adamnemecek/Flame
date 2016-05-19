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

struct BSPVector3 {
    
    var x: Float
    var y: Float
    var z: Float
    
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func toVector3() -> Vector3 {
        return Vector3(x, z, -y)
    }
    
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
    
    var position: BSPVector3
    
    static var dataSize = 12
    
    init?(data: NSData) {
        guard data.length == BSPVertex.dataSize else { return nil }
        let parser = BSPDataParser(data)

        position = BSPVector3(parser.readFloat(), parser.readFloat(), parser.readFloat())
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

struct BSPEdgePointer: BSPLump {
    
    var edgeIndex: Int
    
    static var dataSize = 4
    
    init?(data: NSData) {
        guard data.length == BSPEdgePointer.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        edgeIndex = parser.readLong()
        if edgeIndex > Int(UInt32.max) / 2 {
            edgeIndex = edgeIndex - (Int(UInt32.max) + 1)
        }
    }
    
}

struct BSPTextureInfo : BSPLump {

    var vectorS: BSPVector3
    var offsetS: Float
    var vectorT: BSPVector3
    var offsetT: Float
    var textureIndex: Int
    var animated: Bool
    
    static var dataSize = 40;
    
    init?(data: NSData) {
        guard data.length == BSPTextureInfo.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        vectorS = BSPVector3(parser.readFloat(), parser.readFloat(), parser.readFloat())
        offsetS = parser.readFloat()
        vectorT = BSPVector3(parser.readFloat(), parser.readFloat(), parser.readFloat())
        offsetT = parser.readFloat()
        textureIndex = parser.readLong()
        animated = parser.readLong() == 1
    }
    
    
}

struct BSPMipTex: BSPLump {
    
    var name: String
    var width: Int
    var height: Int
    var offsetMipLevel0: Int
    var offsetMipLevel1: Int
    var offsetMipLevel2: Int
    var offsetMipLevel3: Int
    
    static var dataSize = 40;
    
    init?(data: NSData) {
        guard data.length == BSPMipTex.dataSize else { return nil }
        let parser = BSPDataParser(data)
        
        name = parser.readString(16)
        print(name)
        width = parser.readLong()
        height = parser.readLong()
        offsetMipLevel0 = parser.readLong()
        offsetMipLevel1 = parser.readLong()
        offsetMipLevel2 = parser.readLong()
        offsetMipLevel3 = parser.readLong()
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
