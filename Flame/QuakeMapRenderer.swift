//
//  QuakeMapRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 15/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class QuakeMapRenderer : MeshRenderer {

    struct Mesh {
        var vertexBuffer: MTLBuffer
        var vertexCount: Int
        var textureName: String
    }
    
    var textures = [String: MTLTexture]()
    var meshes = [Mesh]()
    
    var bsp: QuakeBSP? {
        didSet {
            generateBuffers()
        }
    }

    var palette: QuakePalette? {
        didSet {
            generateBuffers()
        }
    }
    
    override func generateBuffers() {
        guard let bsp = bsp else { return }
        guard let palette = palette else { return }

        // Read texture data into MTLTextures.
        textures = createTextures(bsp: bsp, palette: palette)

        // Generate a vertex buffer for level geometry per texture.
        meshes = [Mesh]()
        let device = Renderer.sharedInstance.device

        for (textureName, texture) in textures {
            var vertices = [Vertex]()

            let faces = bsp.faces.filter {
                bsp.mipTextures[bsp.textureInfo[$0.textureIndex].textureIndex].name == textureName
            }
            
            if faces.count == 0 {
                continue
            }

            for face in faces {
                let textureInfo = bsp.textureInfo[face.textureIndex]
                
                // Look up list of face edges and extract vertices.
                var faceVertices = [BSPVertex]()
                var faceUVs = [Vector2]()
                
                for f in 0 ..< face.edgeCount {
                    let faceEdgeIndex = face.firstEdgeIndex + f
                    let edgeIndex = bsp.edgeList[faceEdgeIndex].edgeIndex
                    
                    var vertexIndex = 0
                    
                    // A negative index into the edge list indicates the edge needs to be
                    // inverted for thi bvggs face (end vertex to start vertex).
                    if edgeIndex < 0 {
                        vertexIndex = bsp.edges[abs(edgeIndex)].startVertexIndex
                    }
                    else {
                        vertexIndex = bsp.edges[edgeIndex].endVertexIndex
                    }
                    
                    let bspVertex = bsp.vertices[vertexIndex]
                    faceVertices.append(bspVertex)
                    
                    let vertexPosition = bspVertex.position.toVector3()
                    
                    let textureCoords = Vector2((vertexPosition.dot(textureInfo.vectorS.toVector3()) + textureInfo.offsetS) / Float(texture.width),
                                                (vertexPosition.dot(textureInfo.vectorT.toVector3()) + textureInfo.offsetT) / Float(texture.height))
                    
                    faceUVs.append(textureCoords)
                }
                
                // Assemble triangles and add to vertex buffer.
                var indices = [Int](count: (face.edgeCount - 2) * 3, repeatedValue: 0)
                var triangleStep = 1
                for i in 1 ..< faceVertices.count - 1 {
                    indices[triangleStep - 1] = 0
                    indices[triangleStep] = i
                    indices[triangleStep + 1] = i + 1
                    triangleStep += 3
                }
                
                let white = Vector4(1, 1, 1, 1)
                for index in indices {
                    let v = faceVertices[index]
                    let texCoords = faceUVs[index]
                    vertices.append(Vertex(position: Vector4(v.position.toVector3(), 1), color: white, textureCoords: texCoords))
                }
                
            }

            // Store vertex buffer.
            let meshVertexBuffer = device.newBufferWithBytes(vertices,
                                                             length: vertices.count * sizeof(Vertex),
                                                             options: .CPUCacheModeDefaultCache)

            meshes.append(Mesh(vertexBuffer: meshVertexBuffer, vertexCount: vertices.count, textureName: textureName))
        }

        print("Created \(meshes.count) meshes.")
        
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        for mesh in meshes {
            if let texture = textures[mesh.textureName] {
                commandEncoder.setFragmentTexture(texture, atIndex: 0)
            }
            
            commandEncoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, atIndex: 0)
            commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: mesh.vertexCount, instanceCount: 1)
        }
    }

    private func createTextures(bsp bsp: QuakeBSP, palette: QuakePalette) -> [String: MTLTexture] {
        let device = Renderer.sharedInstance.device
        var result = [String: MTLTexture]()

        for mipTexture in bsp.mipTextures {
            
            guard let textureData = bsp.textureData[mipTexture.name] else {
                continue
            }
            
            let descriptor = MTLTextureDescriptor
                .texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: mipTexture.width, height: mipTexture.height, mipmapped: true)
            let texture = device.newTextureWithDescriptor(descriptor)
            
            let rawDataParser = BSPDataParser(textureData)
            var rgbData = [UInt8](count: textureData.length * 4, repeatedValue: 0x00)
            
            for i in 0 ..< textureData.length {
                rawDataParser.readOffset = i
                let colorIndex = rawDataParser.readByte()
                let color = palette.colors[colorIndex]
                
                let offset = i * 4
                rgbData[offset] = UInt8(color.x * 255)
                rgbData[offset+1] = UInt8(color.y * 255)
                rgbData[offset+2] = UInt8(color.z * 255)
                rgbData[offset+3] = 0xFF
            }
            
            let rawTexture = NSData(bytes: rgbData, length: rgbData.count)
            texture.replaceRegion(MTLRegionMake2D(0, 0, mipTexture.width, mipTexture.height),
                                  mipmapLevel: 0,
                                  withBytes: UnsafePointer<UInt8>(rawTexture.bytes),
                                  bytesPerRow: 4 * mipTexture.width)

            result[mipTexture.name] = texture
        }
        
        return result
    }
    
}
