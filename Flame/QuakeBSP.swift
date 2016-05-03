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
    
    // MARK: - Public API
    
    init?(filePath: String) {
        
        guard let data = NSFileManager.defaultManager().contentsAtPath(filePath) else { return nil }
        let header = readHeader(data)
        
        self.version = header.version
        self.entities = parseEntities(data, lump: header.entities)
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
        header.miptex = readLump(data, index: 1)
        header.planes = readLump(data, index: 2)
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
    
    private func readInt(data: NSData, offset: Int) -> Int {
        let range = NSRange(location: offset, length: sizeof(UInt32))
        var buffer = [UInt32](count: 1, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        return Int(buffer[0].littleEndian)
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
        let offset = sizeof(UInt32) * (4 * index + 1)
        let range = NSRange(location: offset, length: sizeof(UInt32) * 2)
        var buffer = [UInt32](count: 2, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        
        return Lump(offset: Int(buffer[0].littleEndian), size: Int(buffer[1].littleEndian))
    }
    
}
