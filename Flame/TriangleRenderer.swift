//
//  TriangleRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import simd
import MetalKit

class TriangleRenderer : MeshRenderer {

    var colorBuffer: MTLBuffer?

    override func generateBuffers() {
        let device = Renderer.sharedInstance.device
        
        let v1 = float4(0, 0.5, 0, 1)
        let v2 = float4(-0.5, -0.5, 0, 1)
        let v3 = float4(0.5, -0.5, 0, 1)
        
        let positions = decompose([v1, v2, v3])
        
        let c1 = float4(1, 0, 0, 1)
        let c2 = float4(0, 1, 0, 1)
        let c3 = float4(0, 0, 1, 1)
        let colors = decompose([c1, c2, c3])
        
        vertexBuffer = device.newBufferWithBytes(positions, length: positions.count * sizeof(Float), options: .CPUCacheModeDefaultCache)
        colorBuffer = device.newBufferWithBytes(colors, length: colors.count * sizeof(Float) , options: .CPUCacheModeDefaultCache)
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.setVertexBuffer(colorBuffer, offset: 0, atIndex: 1)
        commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    }
    
}