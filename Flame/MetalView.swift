//
//  MetalView.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 27/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class MetalView: MTKView {

    private var timer: UInt64
    
    init?(size: CGSize) {
        timer = mach_absolute_time()

        super.init(frame: CGRect(origin: CGPointZero, size: size), device: Renderer.sharedInstance.device)

        let framebufferSize = convertSizeToBacking(frame.size)
        Swift.print("Frame buffer size: \(Int(framebufferSize.width))x\(Int(framebufferSize.height))")
        
        framebufferOnly = false
        colorPixelFormat = .BGRA8Unorm
        sampleCount = 1
        preferredFramesPerSecond = 60
        autoResizeDrawable = true
    
        Renderer.sharedInstance.setup(framebufferSize)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(dirtyRect: NSRect) {

        let deltaTime = updateDeltaTime()
        Scene.sharedInstance.update(deltaTime)
        
        super.drawRect(dirtyRect)
        Renderer.sharedInstance.render(currentDrawable!)
        
    }

    // MARK: - Private API
    
    private func updateDeltaTime() -> NSTimeInterval {
        let now = mach_absolute_time()
        let delta = now - timer
        timer = now
        
        return NSTimeInterval(Double(delta) / Double(NSEC_PER_SEC))
    }
    
}
