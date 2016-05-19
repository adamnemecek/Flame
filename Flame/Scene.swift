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
        camera.transform.position = Vector3(0, 64, 0)
        entities.append(camera)

        let grid = Entity()
        grid.name = "Grid"
        let gridComponent = grid.addComponent(GridRenderer)
        gridComponent.side = 32
        gridComponent.color = Vector4(0, 0.25, 0, 1)
        entities.append(grid)

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
        
        let quakeMap = Entity()
        quakeMap.name = "QuakeMap"
        let mapRendererComponent = quakeMap.addComponent(QuakeMapRenderer)
        mapRendererComponent.bsp = bsp
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
    
}
