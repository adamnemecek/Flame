//
//  QuakeBSP.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 1/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

class QuakeBSP {

    var version: Int!
    var entities: [QuakeEntity]!
    var planes: [QuakePlane]!
    var vertices: [Vector3]!
    var edges: [QuakeEdge]!
    
    // MARK: - Public API
    
    init?(filePath: String) {
        
        guard let data = NSFileManager.defaultManager().contentsAtPath(filePath) else { return nil }
        let header = readHeader(data)
        
        self.version = header.version
        self.entities = parseEntities(data, lump: header.entities)
        self.planes = parsePlanes(data, lump: header.planes)
        self.vertices = parseVertices(data, lump: header.vertices)
        self.edges = parseEdges(data, lump: header.edges)
    }
    
    // MARK: - Private types
    
    private struct Header {
        var version: Int!
        var entities: Lump!
        var planes: Lump!
        var miptex: Lump!
        var vertices: Lump!
        var visilist: Lump!
        var nodes: Lump!
        var texinfo: Lump!
        var faces: Lump!
        var lightmaps: Lump!
        var clipnodes: Lump!
        var leaves: Lump!
        var lframe: Lump!
        var edges: Lump!
        var ledges: Lump!
        var models: Lump!
    }

    private struct Lump {
        var offset: Int!
        var size: Int!
    }
    
    // MARK: - Private API
    
    private func readHeader(data: NSData) -> Header {
        var header = Header()
        
        header.version = readInt(data, offset: 0)
        header.entities = readLump(data, index: 0)
        header.planes = readLump(data, index: 1)
        header.miptex = readLump(data, index: 2)
        header.vertices = readLump(data, index: 3)
        header.visilist = readLump(data, index: 4)
        header.nodes = readLump(data, index: 5)
        header.texinfo = readLump(data, index: 6)
        header.faces = readLump(data, index: 7)
        header.lightmaps = readLump(data, index: 8)
        header.clipnodes = readLump(data, index: 9)
        header.leaves = readLump(data, index: 10)
        header.lframe = readLump(data, index: 11)
        header.edges = readLump(data, index: 12)
        header.ledges = readLump(data, index: 13)
        header.models = readLump(data, index: 14)
        
        return header
    }
    
    private func parseEntities(data: NSData, lump: Lump) -> [QuakeEntity] {
        
        var result = [QuakeEntity]()
        let definition = readString(data, offset: lump.offset, size: lump.size)
        
        do {
            let entitiesRegex = try NSRegularExpression(pattern: "\\{\\n((?:.*\\n)+?)\\}",
                options: NSRegularExpressionOptions.CaseInsensitive)
            
            let entityDefinitions = entitiesRegex.matchesInString(definition,
                options: NSMatchingOptions.WithTransparentBounds,
                range: NSMakeRange(0, definition.characters.count))
                
                .map { match in
                    (definition as NSString).substringWithRange(match.rangeAtIndex(0))
                }
            
            for entityDefinition in entityDefinitions {
                
                let propertiesRegex = try NSRegularExpression(pattern: ".*\\\"(.*)\\\" \\\"(.*)\\\"\\n",
                    options: NSRegularExpressionOptions.CaseInsensitive)
                
                let properties = propertiesRegex.matchesInString(entityDefinition,
                    options: NSMatchingOptions.WithTransparentBounds,
                    range: NSMakeRange(0, entityDefinition.characters.count))
                    
                    .map({ (match) -> (key: String, value: String) in
                        let def = (entityDefinition as NSString)
                        let key = def.substringWithRange(match.rangeAtIndex(1))
                        let value = def.substringWithRange(match.rangeAtIndex(2))
                        
                        return (key, value)
                    })

                var entity = QuakeEntity()

                if let className = properties.filter({ $0.key == "classname" }).first?.value {
                    
                    entity.className = className
                    
                    if let originDefinition = properties.filter({ $0.key == "origin" }).first?.value {
                        let elements = originDefinition.componentsSeparatedByString(" ")
                        if elements.count == 3 {
                            entity.origin = Vector3(Float(elements[0])!, Float(elements[1])!, Float(elements[2])!)
                        }
                    }

                    for property in properties.filter({ $0.key != "classname" && $0.key != "origin" }) {
                        entity.properties[property.key] = property.value
                    }
                    
                    result.append(entity)
                    
                }
                else {
                    continue
                }
                
            }
            
            return result
            
        }
        catch {
            assertionFailure()
            return [QuakeEntity]()
        }
    }

    private func parsePlanes(data: NSData, lump: Lump) -> [QuakePlane] {
        var result = [QuakePlane]()

        let numPlanes = lump.size / 20

        for planeIndex in 0 ..< numPlanes {
            let offset = lump.offset + planeIndex * 20
            
            let normal = Vector3(readFloat(data, offset: offset), readFloat(data, offset: offset + 4), readFloat(data, offset: offset + 8))
            let distance = readFloat(data, offset: offset + 12)
            let type = readInt(data, offset: offset + 16)
            
            result.append(QuakePlane(normal: normal, distance: distance, type: QuakePlaneType(rawValue: type)!))
        }
        
        return result
    }

    private func parseVertices(data: NSData, lump: Lump) -> [Vector3] {
        var result = [Vector3]()
        
        let numVertices = lump.size / 12
        
        for vertIndex in 0 ..< numVertices {
            let offset = lump.offset + vertIndex * 12
            let vertex = Vector3(readFloat(data, offset: offset), readFloat(data, offset: offset + 4), readFloat(data, offset: offset + 8))
            result.append(vertex)
        }
        
        return result
    }

    private func parseEdges(data: NSData, lump: Lump) -> [QuakeEdge] {
        var result = [QuakeEdge]()
        
        let numEdges = lump.size / 4
        
        for edgeIndex in 0 ..< numEdges {
            let offset = lump.offset + edgeIndex * 4
            let startVertexIndex = readShort(data, offset: offset)
            let endVertexIndex = readShort(data, offset: offset + 2)

            let edge = QuakeEdge(startVertexIndex: startVertexIndex, endVertexIndex: endVertexIndex)
            
            result.append(edge)
        }
        
        return result
    }
    
    private func readInt(data: NSData, offset: Int) -> Int {
        let range = NSRange(location: offset, length: sizeof(UInt32))
        var buffer = [UInt32](count: 1, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        return Int(buffer[0].littleEndian)
    }
    
    private func readShort(data: NSData, offset: Int) -> Int {
        let range = NSRange(location: offset, length: sizeof(UInt32))
        var buffer = [UInt16](count: 1, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        return Int(buffer[0].littleEndian)
    }
    
    private func readFloat(data: NSData, offset: Int) -> Float {
        let range = NSRange(location: offset, length: sizeof(Float32))
        var buffer = [Float32](count: 1, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        return Float(buffer[0])
    }
    
    private func readString(data: NSData, offset: Int, size: Int) -> String {
        var buffer = [Int8](count: size, repeatedValue: 0)
        data.getBytes(&buffer, range: NSRange(location: offset, length: size))
        
        var result = ""
        for c in buffer {
            if c == 0 { break }
            result.append(Character(UnicodeScalar(Int(c))))
        }
        
        return result
    }

    private func readLump(data: NSData, index: Int) -> Lump {
        let offset = sizeof(UInt32) * (1 + index * 2)
        let range = NSRange(location: offset, length: sizeof(UInt32) * 2)
        var buffer = [UInt32](count: 2, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        
        return Lump(offset: Int(buffer[0].littleEndian), size: Int(buffer[1].littleEndian))
    }
    
}
