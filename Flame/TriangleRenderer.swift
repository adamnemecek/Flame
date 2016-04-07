//
//  TriangleRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import simd
import MetalKit

struct Vertex {
    var position: float4
    var color: float4
}

class TriangleRenderer : MeshRenderer {

    private var color1: float4
    private var color2: float4
    private var color3: float4
    
    init(color1: float3 = float3(1, 0, 0), color2: float3 = float3(0, 1, 0), color3: float3 = float3(0, 0, 1)) {
        self.color1 = float4(color1.x, color1.y, color1.z, 1)
        self.color2 = float4(color2.x, color2.y, color2.z, 1)
        self.color3 = float4(color3.x, color3.y, color3.z, 1)
        
        super.init()
    }
    
    override func generateBuffers() {
        let device = Renderer.sharedInstance.device

        let v0 = Vertex(position: float4(-0.5, 0, 0, 1), color: color1)
        let v1 = Vertex(position: float4(0, 1, 0, 1), color: color2)
        let v2 = Vertex(position: float4(0.5, 0, 0, 1), color: color3)
        
        vertexBuffer = device.newBufferWithBytes([v0, v1, v2], length: 3 * sizeof(Vertex), options: .CPUCacheModeDefaultCache)
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    }
    
}