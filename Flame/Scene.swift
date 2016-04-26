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
        camera.transform.position = Vector3(0, 0.7, 3)
        entities.append(camera)

        let grid = Entity()
        grid.name = "Grid"

        let gridComponent = grid.addComponent(GridRenderer)
        gridComponent.side = 32
        gridComponent.color = Vector4(0, 0.25, 0, 1)
        
        entities.append(grid)
        
        let triangle = Entity()
        triangle.name = "Triangle"
        triangle.addComponent(TriangleRenderer)
        triangle.transform.position = Vector3(-1, 0.5, 0)
        
        let tSpinner = triangle.addComponent(Spinner)
        tSpinner.speed = 1.0
        
        entities.append(triangle)

        let cube = Entity()
        cube.name = "Cube"
        cube.addComponent(CubeRenderer)
        cube.transform.position = Vector3(1, 0.5, 0)
        entities.append(cube)
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
