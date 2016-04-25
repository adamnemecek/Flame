//
//  TriangleRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

struct Vertex {
    var position: Vector4
    var color: Vector4
}

class TriangleRenderer : MeshRenderer {

    private var color1: Vector4
    private var color2: Vector4
    private var color3: Vector4
 
    required init() {
        self.color1 = Vector4(1, 0, 0, 1)
        self.color2 = Vector4(0, 1, 0, 1)
        self.color3 = Vector4(0, 0, 1, 1)
        
        super.init()
    }
    
    override func generateBuffers() {
        let device = Renderer.sharedInstance.device

        let v0 = Vertex(position: Vector4(-0.5, -0.5, 0, 1), color: color1)
        let v1 = Vertex(position: Vector4(0, 0.5, 0, 1), color: color2)
        let v2 = Vertex(position: Vector4(0.5, -0.5, 0, 1), color: color3)
        
        vertexBuffer = device.newBufferWithBytes([v0, v1, v2], length: 3 * sizeof(Vertex), options: .CPUCacheModeDefaultCache)
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    }
    
}