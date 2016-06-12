//
//  QuakeTextureAtlas.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 6/06/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

struct QuakeTextureAtlas {
 
    var texture: MTLTexture
    
    init?(bsp: QuakeBSP, palette: QuakePalette) {

        let atlasWidth = bsp.mipTextures.reduce(0) { (total, mipTex) -> Int in
            return total + mipTex.width
        }
        
        let atlasHeight = bsp.mipTextures.reduce(0) { (maximum, mipTex) -> Int in
            return max(maximum, mipTex.height)
        }
        
        print("atlas size: \(atlasWidth) x \(atlasHeight)")
        
        let numTextures = bsp.mipTextures.count
        let mipTex = bsp.mipTextures[numTextures - 38]
        
        if !bsp.textureData.keys.contains(mipTex.name) {
            fatalError("Couldn't find texture data for \(mipTex.name).")
        }
            
        guard let rawData = bsp.textureData[mipTex.name] else {
            fatalError("Texture data size for \(mipTex.name) is zero.")
        }
            
        let rawDataParser = BSPDataParser(rawData)
        var rgbData = [UInt8](count: rawData.length * 4, repeatedValue: 0x00)
            
        for i in 0 ..< rawData.length {
            rawDataParser.readOffset = i
            let colorIndex = rawDataParser.readByte()
            let color = palette.colors[colorIndex]
                
            let offset = i * 4
            rgbData[offset] = UInt8(color.x * 255)
            rgbData[offset+1] = UInt8(color.y * 255)
            rgbData[offset+2] = UInt8(color.z * 255)
            rgbData[offset+3] = 0xFF
        }
            
        let device = Renderer.sharedInstance.device
        let descriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: mipTex.width, height: mipTex.height, mipmapped: true)
        
        texture = device.newTextureWithDescriptor(descriptor)
            
        let rawTexture = NSData(bytes: rgbData, length: rgbData.count)
        texture.replaceRegion(MTLRegionMake2D(0, 0, mipTex.width, mipTex.height),
                                  mipmapLevel: 0,
                                  withBytes: UnsafePointer<UInt8>(rawTexture.bytes),
                                  bytesPerRow: 4 * mipTex.width)

        mappings = [TextureMapping]()
 
    }
    
    func textureOffset(textureName: String) -> (uOffset: Double, vOffset: Double)? {
        return (0, 0)
    }
    
    func textureScale(textureName: String) -> (uScale: Double, vScale: Double)? {
        return (0, 0)
    }
    
    // MARK: - Private API

    private struct TextureMapping {
        var textureName: String
        var texelOffset: (Int, Int)
        var texelArea: (Int, Int)
    }
    
    private var mappings: [TextureMapping]

}
