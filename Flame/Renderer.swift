//
//  Renderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 3/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class Renderer {
    
    static let sharedInstance = Renderer()
    
    // MARK: - Properties
    
    var device: MTLDevice!
    
    private var commandQueue: MTLCommandQueue!
    private var defaultLibrary: MTLLibrary!
    private var pipeline: MTLRenderPipelineState?
    
    // MARK: - Init & deinit
    
    init() {
        device = MTLCreateSystemDefaultDevice()
        
        commandQueue = device.newCommandQueue()
        defaultLibrary = device.newDefaultLibrary()!

        setupRenderPipeline()
    }
    
    func setup() {
    }
    
    // MARK: - Public API

    func render(drawable: CAMetalDrawable) {
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = drawable.texture
        renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 0.15, green: 0.16, blue: 0.19, alpha: 0)
        renderPass.colorAttachments[0].loadAction = .Clear
        renderPass.colorAttachments[0].storeAction = .Store
        
        let commandQueue = device.newCommandQueue()
        let commandBuffer = commandQueue.commandBuffer()
        
        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPass)
        commandEncoder.setRenderPipelineState(pipeline!)
        
        for meshRenderer in Scene.sharedInstance.getMeshRenderers() {
            meshRenderer.draw(commandEncoder)
        }
        
        commandEncoder.endEncoding()
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }

    
    // MARK: - Private API
    
    private func setupRenderPipeline() {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .Float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        
        vertexDescriptor.attributes[1].format = .Float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = sizeof(Float) * 4
        
        vertexDescriptor.layouts[0].stride = sizeof(Float) * 8
        vertexDescriptor.layouts[0].stepFunction = .PerVertex
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = defaultLibrary.newFunctionWithName("vertex_main")
        pipelineDescriptor.fragmentFunction = defaultLibrary.newFunctionWithName("fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipeline = try! device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
    }
    
}

