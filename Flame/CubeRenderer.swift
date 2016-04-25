//
//  CubeRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 8/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class CubeRenderer : MeshRenderer {

    private var numVertices = 0
    private var numIndices = 0
    
    override func generateBuffers() {
        let device = Renderer.sharedInstance.device
        
        let a = Vertex(position: Vector4(-0.5, 0.5, 0.5, 1), color: Vector4(1, 0, 0, 1))
        let b = Vertex(position: Vector4(-0.5, -0.5, 0.5, 1), color: Vector4(0, 1, 0, 1))
        let c = Vertex(position: Vector4(0.5, -0.5, 0.5, 1), color: Vector4(0, 0, 1, 1))
        let d = Vertex(position: Vector4(0.5, 0.5, 0.5, 1), color: Vector4(1, 1, 0, 1))

        let q = Vertex(position: Vector4(-0.5, 0.5, -0.5, 1), color: Vector4(0, 1, 1, 1))
        let r = Vertex(position: Vector4(0.5, 0.5, -0.5, 1), color: Vector4(1, 0, 1, 1))
        let s = Vertex(position: Vector4(-0.5, -0.5, -0.5, 1), color: Vector4(0, 1, 0, 1))
        let t = Vertex(position: Vector4(0.5, -0.5, -0.5, 1), color: Vector4(1, 0, 0, 1))

        let vertices = [a, b, c, d, q, r, s, t]
        
        let indices: [UInt16] = [
            0, 1, 2, 0, 2, 3,
            5, 7, 6, 4, 5, 6,
            
            4, 6, 1, 4, 1, 0,
            3, 2, 7, 3, 7, 5,
            
            4, 0, 3, 4, 3, 5,
            1, 6, 7, 1, 7, 2
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
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        
        commandEncoder.drawIndexedPrimitives(.Triangle,
            indexCount: numIndices,
            indexType: .UInt16,
            indexBuffer: indexBuffer!,
            indexBufferOffset: 0)
    }
    
}