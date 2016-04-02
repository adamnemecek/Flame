//
//  MeshRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import GameplayKit
import MetalKit
import simd

class MeshRenderer : GKComponent {

    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    override init() {
        super.init()
        generateBuffers()
    }
    
    func generateBuffers() {
    }
    
    func draw(commandEncoder: MTLRenderCommandEncoder) {
    }
    
}
