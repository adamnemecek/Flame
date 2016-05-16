//
//  QuakeMapRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 15/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class QuakeMapRenderer : MeshRenderer {
    
    var bsp: QuakeBSP? {
        didSet {
            generateBuffers()
        }
    }
    
    private var vertexCount = 0
    
    override func generateBuffers() {
        guard let bsp = bsp else { return }
        
        let device = Renderer.sharedInstance.device

        vertexCount = bsp.edges.count * 2
        var vertices = [Vertex]()

        let defaultColor = Vector4(1, 1, 1, 1)

        for edge in bsp.edges {
            let v0 = bsp.vertices[edge.startVertexIndex]
            let v1 = bsp.vertices[edge.endVertexIndex]
            
            vertices.append(Vertex(position: Vector4(v0.x, v0.z, -v0.y, 1), color: defaultColor))
            vertices.append(Vertex(position: Vector4(v1.x, v1.z, -v1.y, 1), color: defaultColor))
        }
        
        vertexBuffer = device.newBufferWithBytes(vertices,
            length: vertices.count * sizeof(Vertex),
            options: .CPUCacheModeDefaultCache)
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.drawPrimitives(.Line, vertexStart: 0, vertexCount: vertexCount)
    }
    
}
