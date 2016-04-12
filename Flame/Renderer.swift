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

    private var depthStencilState: MTLDepthStencilState?
    private var depthTexture: MTLTexture!
    
    // MARK: - Init & deinit
    
    init() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.newCommandQueue()
        defaultLibrary = device.newDefaultLibrary()!
    }
    
    // MARK: - Public API

    func render(drawable: CAMetalDrawable) {
        guard let camera = Scene.sharedInstance.camera else { return }
        
        let renderPass = MTLRenderPassDescriptor()

        renderPass.colorAttachments[0].texture = drawable.texture
        renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 0.15, green: 0.16, blue: 0.19, alpha: 0)
        renderPass.colorAttachments[0].loadAction = .Clear
        renderPass.colorAttachments[0].storeAction = .Store
        
        renderPass.depthAttachment.texture = depthTexture
        renderPass.depthAttachment.loadAction = .Clear
        renderPass.depthAttachment.storeAction = .Store
        renderPass.depthAttachment.clearDepth = 1.0
        
        let commandQueue = device.newCommandQueue()
        let commandBuffer = commandQueue.commandBuffer()
        
        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPass)
        
        if let pipelineState = pipeline {
            commandEncoder.setRenderPipelineState(pipelineState)
        }
        
        if let depthStencilState = depthStencilState {
            commandEncoder.setDepthStencilState(depthStencilState)
        }

        camera.aspect = Float(drawable.texture.width) / Float(drawable.texture.height)
        
        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix
        
        for meshRenderer in Scene.sharedInstance.getMeshRenderers() {
            if let entity = meshRenderer.entity as? Entity {
                let modelMatrix = entity.transform.modelMatrix
                let mvpMatrix = projectionMatrix * viewMatrix * modelMatrix

                let uniformBuffer = device.newBufferWithLength(sizeof(Float) * 16, options: .CPUCacheModeDefaultCache)
                let uniformBufferPtr = uniformBuffer.contents()
                memcpy(uniformBufferPtr, mvpMatrix.decompose(), sizeof(Float) * 16)
                
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
                
                meshRenderer.draw(commandEncoder)
            }
        }
        
        commandEncoder.endEncoding()
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }

    func setup(framebufferSize: CGSize) {
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
        pipelineDescriptor.depthAttachmentPixelFormat = .Depth32Float
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipeline = try! device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .Less
        depthStencilState = device.newDepthStencilStateWithDescriptor(depthStencilDescriptor)
        
        let depthTextureDescriptor = MTLTextureDescriptor()
        depthTextureDescriptor.resourceOptions = .StorageModePrivate
        depthTextureDescriptor.usage = .RenderTarget
        depthTextureDescriptor.pixelFormat = .Depth32Float
        depthTextureDescriptor.width = Int(framebufferSize.width)
        depthTextureDescriptor.height = Int(framebufferSize.height)
        depthTexture = device.newTextureWithDescriptor(depthTextureDescriptor)
    }
    
}
