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
    var entities: [BSPEntity]!
    var vertices: [BSPVertex]!
    var edges: [BSPEdge]!
    
    // MARK: - Public API
    
    init?(filePath: String) {
        guard let data = NSFileManager.defaultManager().contentsAtPath(filePath) else {
            print("❌ Couldn't read BSP file at \(filePath).")
            return nil
        }
        
        let parser = BSPDataParser(data)
        version = parser.readLong()
        
        if version != 29 {
            print("❌ Unsupported BSP format.")
            return nil
        }
        
        let headerEntries: [BSPHeaderEntry] = parse(data, offset: sizeof(Int32), size: 14 * BSPHeaderEntry.dataSize)
        
        if headerEntries.count != 14 {
            print("❌ Invalid header entry count in BSP file.")
            return nil
        }

        // Read entities definition.
        parser.readOffset = headerEntries[HeaderIndex.Entities].offset
        let entitiesDefinition = parser.readString(headerEntries[HeaderIndex.Entities].size)
        entities = parseEntities(entitiesDefinition)
        
        vertices = parse(data, headerEntry: headerEntries[HeaderIndex.Vertices])
        edges = parse(data, headerEntry: headerEntries[HeaderIndex.Edges])
    }

    // MARK: - Private types
    
    private struct HeaderIndex {
        static let Entities = 0
        static let Planes = 1
        static let MipTex = 2
        static let Vertices = 3
        static let VisiList = 4
        static let Nodes = 5
        static let TexInfo = 6
        static let Faces = 7
        static let Lightmaps = 8
        static let Clipnodes = 9
        static let Leaves = 10
        static let LFrame = 11
        static let Edges = 12
        static let Ledges = 13
        static let Models = 14
    }
    
    // MARK: - Private API

    private func parse<T where T: BSPLump>(data: NSData, offset: Int, size: Int) -> [T] {
        let lumpSize = T.dataSize
        let numLumps = size / lumpSize
        
        var result = [T]()
        
        for lumpIndex in 0 ..< numLumps {
            let recordData = data.subdataWithRange(NSRange(location: offset + lumpIndex * lumpSize, length: lumpSize))
            
            if let record = T(data: recordData) {
                result.append(record)
            }
            else {
                Swift.print("❌ Failed to create \(T.self) #\(lumpIndex).")
            }
        }
        
        return result
    }
    
    
    private func parse<T where T: BSPLump>(data: NSData, headerEntry: BSPHeaderEntry) -> [T] {
        return parse(data, offset: headerEntry.offset, size: headerEntry.size)
    }

    private func parseEntities(definition: String) -> [BSPEntity] {
        
        var result = [BSPEntity]()
        
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

                var entity = BSPEntity()

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
            return [BSPEntity]()
        }
    }

}
