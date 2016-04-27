//: Playground - noun: a place where people can play

import Cocoa

extension NSInputStream {
    func readInt32() -> Int {
    var buffer = Array<UInt8>(count:sizeof(Int32), repeatedValue: 0)
        read(&buffer, maxLength: buffer.count)
        
        var result = Int(buffer[0])
        result |= Int(buffer[1]) << 8
        result |= Int(buffer[2]) << 16
        result |= Int(buffer[3]) << 24
        
        return result
    }
}

struct BSPEntry {
    var offset: Int!
    var size: Int!
}

struct BSPHeader {
    var version: Int!
    var entities: BSPEntry!
    var planes: BSPEntry!
    var miptex: BSPEntry!
    var vertices: BSPEntry!
    var visilist: BSPEntry!
    var nodes: BSPEntry!
    var texinfo: BSPEntry!
    var faces: BSPEntry!
    var lightmaps: BSPEntry!
    var clipnodes: BSPEntry!
    var leaves: BSPEntry!
    var lframe: BSPEntry!
    var edges: BSPEntry!
    var ledges: BSPEntry!
    var models: BSPEntry!
}

func readEntry(stream: NSInputStream) -> BSPEntry? {
    var result = BSPEntry()
        result.offset = stream.readInt32()
    result.size = stream.readInt32()
    
    return result
}

func readHeader(stream: NSInputStream) -> BSPHeader? {
    stream.setProperty(0, forKey: NSStreamFileCurrentOffsetKey)
    
    var header = BSPHeader()
    header.version = stream.readInt32()
    header.entities = readEntry(stream)
    header.planes = readEntry(stream)
    header.miptex = readEntry(stream)
    header.vertices = readEntry(stream)
    header.visilist = readEntry(stream)
    header.nodes = readEntry(stream)
    header.texinfo = readEntry(stream)
    header.faces = readEntry(stream)
    header.lightmaps = readEntry(stream)
    header.clipnodes = readEntry(stream)
    header.leaves = readEntry(stream)
    header.lframe = readEntry(stream)
    header.edges = readEntry(stream)
    header.ledges = readEntry(stream)
    header.models = readEntry(stream)
    
    return header
}

let bspFile = NSBundle.mainBundle().pathForResource("bsptest", ofType: "bsp")
let bspData = NSFileManager.defaultManager().contentsAtPath(bspFile!)

let stream = NSInputStream(data: bspData!)
stream.open()

if let bspHeader = readHeader(stream) {
    bspHeader.version
    bspHeader.entities
    bspHeader.planes
    bspHeader.miptex
    bspHeader.vertices
    bspHeader.visilist
    bspHeader.nodes
    bspHeader.texinfo
    bspHeader.faces
    bspHeader.lightmaps
    bspHeader.clipnodes
    bspHeader.leaves
    bspHeader.lframe
    bspHeader.edges
    bspHeader.ledges
    bspHeader.models
}

stream.close()

