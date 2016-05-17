//
//  BSPDataParser.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 17/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

/**
 Convenience wrapper around NSData for easy sequential access to
 binary data inside BSP files (or any binary file).
*/
class BSPDataParser {
    
    var readOffset: Int
    private var data: NSData!
    
    init(_ data: NSData) {
        self.data = data
        readOffset = 0
    }
    
    func readShort() -> Int {
        let range = NSRange(location: readOffset, length: sizeof(UInt16))
        var buffer = [UInt16](count: 1, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        readOffset += sizeof(UInt16)
        
        return Int(buffer[0].littleEndian)
    }
    
    func readLong() -> Int {
        let range = NSRange(location: readOffset, length: sizeof(UInt32))
        var buffer = [UInt32](count: 1, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        readOffset += sizeof(UInt32)
        
        return Int(buffer[0].littleEndian)
    }
    
    func readFloat() -> Float {
        let range = NSRange(location: readOffset, length: sizeof(Float32))
        var buffer = [Float32](count: 1, repeatedValue: 0)
        
        data.getBytes(&buffer, range: range)
        readOffset += sizeof(Float32)
        
        return Float(buffer[0])
    }
    
    func readString(length: Int) -> String {
        var buffer = [Int8](count: length, repeatedValue: 0)
        data.getBytes(&buffer, range: NSRange(location: readOffset, length: length))
        
        var result = ""
        for c in buffer {
            if c == 0 { break }
            result.append(Character(UnicodeScalar(Int(c))))
        }
        
        readOffset += length
        
        return result
    }
    
}
