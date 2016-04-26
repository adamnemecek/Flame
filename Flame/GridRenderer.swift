//
//  GridRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 26/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class GridRenderer : MeshRenderer {

    var side: Float = 10 {
        didSet {
            generateBuffers()
        }
    }
    
    var tileSize: Float = 1 {
        didSet {
            generateBuffers()
        }
    }

    var color: Vector4 = Vector4(0, 1, 0, 1) {
        didSet {
            generateBuffers()
        }
    }
    
    private var vertexCount = 0
    
    override func generateBuffers() {
        let device = Renderer.sharedInstance.device
        
        let subdivisions = Int(side / tileSize)
        let reach = side / 2
        vertexCount = (subdivisions + 1) * 4
        
        var vertices = [Vertex]()
        
        for i in 0 ..< subdivisions {
            vertices.append(Vertex(position: Vector4(-reach, 0, -reach + Float(i) * tileSize, 1), color: color))
            vertices.append(Vertex(position: Vector4(reach, 0, -reach + Float(i) * tileSize, 1), color: color))
            vertices.append(Vertex(position: Vector4(-reach + Float(i) * tileSize, 0, -reach, 1), color: color))
            vertices.append(Vertex(position: Vector4(-reach + Float(i) * tileSize, 0, reach, 1), color: color))
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
