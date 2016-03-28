//
//  MetalView.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 27/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit
import simd

class MetalView: MTKView {

    private var metalDevice: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var defaultLibrary: MTLLibrary!
    
    private var vertexPositions: MTLBuffer?
    private var vertexColors: MTLBuffer?
    private var pipeline: MTLRenderPipelineState?
    
    init?(size: CGSize) {
        
        super.init(frame: CGRect(origin: CGPointZero, size: size), device: MTLCreateSystemDefaultDevice())
        
        metalDevice = MTLCreateSystemDefaultDevice()
        
        guard metalDevice != nil else {
            Swift.print("Failed to create a system default device.")
            return nil
        }

        framebufferOnly = false
        colorPixelFormat = .BGRA8Unorm
        sampleCount = 1
        preferredFramesPerSecond = 60
        autoResizeDrawable = true
        
        // Metal setup.
        commandQueue = metalDevice.newCommandQueue()
        defaultLibrary = metalDevice.newDefaultLibrary()!
        
        setupGeometry()
        setupRenderPipeline()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        render()
    }
    
    func setupGeometry() {
        
        let v1 = float4(0, 0.5, 0, 1)
        let v2 = float4(-0.5, -0.5, 0, 1)
        let v3 = float4(0.5, -0.5, 0, 1)
        let positions = decompose([v1, v2, v3])
        
        let c1 = float4(1, 0, 0, 1)
        let c2 = float4(0, 1, 0, 1)
        let c3 = float4(0, 0, 1, 1)
        let colors = decompose([c1, c2, c3])
        
        vertexPositions = metalDevice.newBufferWithBytes(positions, length: positions.count * sizeof(Float), options: .CPUCacheModeDefaultCache)
        vertexColors = metalDevice.newBufferWithBytes(colors, length: colors.count * sizeof(Float) , options: .CPUCacheModeDefaultCache)
    }
    
    func setupRenderPipeline() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = defaultLibrary.newFunctionWithName("vertex_main")
        pipelineDescriptor.fragmentFunction = defaultLibrary.newFunctionWithName("fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        
        pipeline = try! metalDevice.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
    }
    
    func render() {
        let framebuffer = currentDrawable!.texture
        
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = framebuffer
        renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 0.15, green: 0.16, blue: 0.19, alpha: 0)
        renderPass.colorAttachments[0].loadAction = .Clear
        renderPass.colorAttachments[0].storeAction = .Store

        let commandQueue = metalDevice.newCommandQueue()
        let commandBuffer = commandQueue.commandBuffer()
        
        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPass)
        commandEncoder.setRenderPipelineState(pipeline!)
        commandEncoder.setVertexBuffer(vertexPositions, offset: 0, atIndex: 0)
        commandEncoder.setVertexBuffer(vertexColors, offset: 0, atIndex: 1)
        commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        commandEncoder.endEncoding()

        commandBuffer.presentDrawable(currentDrawable!)
        commandBuffer.commit()
    }
    
}
