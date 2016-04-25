//
//  MeshRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class MeshRenderer : Component {

    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    required init() {
        super.init()
        generateBuffers()
    }
    
    func generateBuffers() {
    }
    
    func draw(commandEncoder: MTLRenderCommandEncoder) {
    }
    
}
