//
//  Scene.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation
import MetalKit

class Scene {
    
    static let sharedInstance = Scene()

    // MARK: - Properties
    
    var entities = [Entity]()
    
    var camera: Camera? {
        for entity in entities {
            if let camera = entity.getComponent(Camera) {
                return camera
            }
        }
        
        return nil
    }

    // MARK: - Init & deinit
    
    func setup() {
        let camera = Entity()
        
        camera.name = "Camera"
        camera.addComponent(Camera)
        camera.transform.position = Vector3(0, 128, 512)
        entities.append(camera)
        
        /*
        let grid = Entity()
        grid.name = "Grid"
        let gridComponent = grid.addComponent(GridRenderer)
        gridComponent.side = 128
        gridComponent.color = Vector4(0, 0.5, 0, 1)
        grid.transform.scale = Vector3(128, 128, 128)
        entities.append(grid)
         */

        guard let bspFilePath = NSBundle.mainBundle().pathForResource("e1m1", ofType: "bsp") else {
            print("BSP file not found.")
            return
        }

        let bspImportStartTime = mach_absolute_time()
        
        guard let bsp = QuakeBSP(filePath: bspFilePath) else {
            print("Failed to parse BSP file.")
            return
        }
        
        let bspImportEndTime = mach_absolute_time()
        let bspImportTime = NSTimeInterval(Double(bspImportEndTime - bspImportStartTime) / Double(NSEC_PER_SEC))
        print("Imported BSP in \(bspImportTime * 1000) ms.")
        
        print("\(bsp.edges.count) edges")
        print("\(bsp.vertices.count) vertices")
        print("\(bsp.entities.count) entities")
        print("\(bsp.planes.count) planes")
        print("\(bsp.faces.count) faces")

        guard let paletteFilePath = NSBundle.mainBundle().pathForResource("palette", ofType: "lmp") else {
            print("❌ Palette file not found.")
            return
        }

        guard let paletteData = NSFileManager.defaultManager().contentsAtPath(paletteFilePath) else {
            print("❌ Couldn't read palette file.")
            return
        }
        
        guard let palette = QuakePalette(data: paletteData) else { return }
        guard let textureAtlas = QuakeTextureAtlas(bsp: bsp, palette: palette) else { return }
        
        let quakeMap = Entity()
        quakeMap.name = "QuakeMap"
        let mapRendererComponent = quakeMap.addComponent(QuakeMapRenderer)
        mapRendererComponent.bsp = bsp
        mapRendererComponent.textureAtlas = textureAtlas
        entities.append(quakeMap)
        
        // Try to move camera to the first info_player_start in the map.
        if let playerStart = bsp.entities.filter({ $0.className == "info_player_start" }).first {
            if let pos = playerStart.origin {
                camera.transform.position = Vector3(pos.x, pos.z + 32, -pos.y)
            }
            
            if playerStart.properties.keys.contains("angle") {
                if let angle = Float(playerStart.properties["angle"]!) {
                    camera.transform.rotation.y = (angle - 90) * Scalar.RadiansPerDegree
                }
            }
            
        }
        
    }
    
    // MARK: - Public API
    
    func update(deltaTime: NSTimeInterval) {
        for entity in entities {
            entity.update(deltaTime)
        }
    }

    func getMeshRenderers() -> [MeshRenderer] {
        var renderers = [MeshRenderer]()
        
        for entity in entities {
            for renderer in entity.getComponents(MeshRenderer) {
                renderers.append(renderer)
            }
        }
        
        return renderers
    }
    
    // MARK: - Private API

    private func createQuakeTexture(bsp: QuakeBSP, palette: QuakePalette) -> MTLTexture? {
        
        var totalTexels = 0
        
        for tex in bsp.mipTextures {
            print(tex.name)
            totalTexels += tex.width * tex.height
        }
        
        let atlasSide = Int(ceil(sqrt(Double(totalTexels))))
        print("Total area: \(totalTexels) texels (approx. \(atlasSide)x\(atlasSide))")

        return nil
    }
    
}
