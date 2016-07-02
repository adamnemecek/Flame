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

    private var textureSampler: MTLSamplerState?
    private var fallbackTexture: MTLTexture?
    
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
        renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0)
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
        
        if let textureSampler = textureSampler {
            commandEncoder.setFragmentSamplerState(textureSampler, atIndex: 0)
        }
        
        commandEncoder.setFrontFacingWinding(.Clockwise)
        commandEncoder.setCullMode(.Back)
        
        camera.aspect = Float(drawable.texture.width) / Float(drawable.texture.height)
        
        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix
        
        for meshRenderer in Scene.sharedInstance.getMeshRenderers() {
            
            if meshRenderer.hidden {
                continue
            }
            
            if let entity = meshRenderer.entity {
                let modelMatrix = entity.transform.matrix
         
                let mvpMatrix = projectionMatrix * viewMatrix * modelMatrix

                let uniformBuffer = device.newBufferWithLength(sizeof(Float) * 16, options: .CPUCacheModeDefaultCache)
                let uniformBufferPtr = uniformBuffer.contents()
                memcpy(uniformBufferPtr, mvpMatrix.toArray(), sizeof(Float) * 16)
                
                commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
                
                if let fallbackTexture = fallbackTexture {
                    commandEncoder.setFragmentTexture(fallbackTexture, atIndex: 0)
                }

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

        vertexDescriptor.attributes[2].format = .Float2
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.attributes[2].offset = sizeof(Float) * 8
        
        vertexDescriptor.layouts[0].stride = sizeof(Vertex)
        vertexDescriptor.layouts[0].stepRate = 1
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
        
        createDepthTexture(framebufferSize)

        let textureSamplerDescriptor = MTLSamplerDescriptor()
        textureSamplerDescriptor.minFilter = .Nearest
        textureSamplerDescriptor.magFilter = .Nearest
        textureSamplerDescriptor.sAddressMode = .Repeat
        textureSamplerDescriptor.tAddressMode = .Repeat
        textureSampler = device.newSamplerStateWithDescriptor(textureSamplerDescriptor)

        let fallbackTextureSize = 8

        let fallbackTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: fallbackTextureSize, height: fallbackTextureSize, mipmapped: true)
        fallbackTexture = device.newTextureWithDescriptor(fallbackTextureDescriptor)

        let rawData = [UInt8](count: fallbackTextureSize * fallbackTextureSize * 4, repeatedValue: 0xFF)
        let rawTexture = NSData(bytes: rawData as [UInt8], length: rawData.count)
        fallbackTexture?.replaceRegion(MTLRegionMake2D(0, 0, fallbackTextureSize, fallbackTextureSize),
                                       mipmapLevel: 0,
                                       withBytes: UnsafePointer<UInt8>(rawTexture.bytes),
                                       bytesPerRow: 4 * fallbackTextureSize)
    }

    func resizeView(toSize size: NSSize) {
        createDepthTexture(size)
    }
    
    // MARK: - Private API
    
    private func createDepthTexture(size: NSSize) {
        let depthTextureDescriptor = MTLTextureDescriptor()
        depthTextureDescriptor.resourceOptions = .StorageModePrivate
        depthTextureDescriptor.usage = .RenderTarget
        depthTextureDescriptor.pixelFormat = .Depth32Float
        depthTextureDescriptor.width = Int(size.width)
        depthTextureDescriptor.height = Int(size.height)
        
        depthTexture = device.newTextureWithDescriptor(depthTextureDescriptor)
    }
    
}
