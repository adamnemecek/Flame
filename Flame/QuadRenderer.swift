//
//  QuadRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class QuadRenderer : MeshRenderer {

    private var numVertices = 0
    private var numIndices = 0

    var texture: MTLTexture?

    override func generateBuffers() {
        let device = Renderer.sharedInstance.device

        let white = Vector4(1, 1, 1, 1)
        
        let v0 = Vertex(position: Vector4(-0.5, -0.5, 0, 1), color: white, textureCoords: Vector2(0,1))
        let v1 = Vertex(position: Vector4(-0.5, 0.5, 0, 1), color: white, textureCoords: Vector2(0,0))
        let v2 = Vertex(position: Vector4(0.5, 0.5, 0, 1), color: white, textureCoords: Vector2(1,0))
        let v3 = Vertex(position: Vector4(0.5, -0.5, 0, 1), color: white, textureCoords: Vector2(1,1))

        let vertices = [v0, v1, v2, v3]
        let indices: [UInt16] = [
            0, 1, 2,
            0, 2, 3
        ]
        
        numVertices = vertices.count
        numIndices = indices.count
        
        vertexBuffer = device.newBufferWithBytes(vertices,
                                                 length: vertices.count * sizeof(Vertex),
                                                 options: .CPUCacheModeDefaultCache)
        
        indexBuffer = device.newBufferWithBytes(indices,
                                                length: indices.count * sizeof(UInt16),
                                                options: .CPUCacheModeDefaultCache)
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        
        if let texture = texture {
            commandEncoder.setFragmentTexture(texture, atIndex: 0)
        }
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.drawIndexedPrimitives(.Triangle,
                                             indexCount: numIndices,
                                             indexType: .UInt16,
                                             indexBuffer: indexBuffer!,
                                             indexBufferOffset: 0)
        
    }
    
}