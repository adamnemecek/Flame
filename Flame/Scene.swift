//
//  Scene.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 29/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation
import GameplayKit
import MetalKit
import simd

class Scene {
    
    static let sharedInstance = Scene()

    // MARK: - Properties
    
    var entities = [Entity]()
    
    var camera: Camera? {
        for entity in entities {
            for component in entity.components {
                if let cameraComponent = component as? Camera {
                    return cameraComponent
                }
            }
        }
        
        return nil
    }

    // MARK: - Init & deinit
    
    func setup() {
        let camera = Entity()
        camera.name = "Camera"
        camera.addComponent(Camera())
        camera.transform.position = float3(0, 0, 3)
        entities.append(camera)

        let triangle = Entity()
        triangle.name = "Triangle"
        triangle.addComponent(TriangleRenderer())
        triangle.transform.position = float3(-1, 0, 0)
        triangle.addComponent(Spinner(speed: 1.0))
        entities.append(triangle)

        let cube = Entity()
        cube.name = "Cube"
        cube.addComponent(CubeRenderer())
        cube.transform.position = float3(1, 0, 0)
        cube.addComponent(Spinner(speed: 0.45))
        entities.append(cube)
    }
    
    // MARK: - Public API
    
    func update(deltaTime: NSTimeInterval) {
        for entity in entities {
            entity.updateWithDeltaTime(deltaTime)
        }
    }

    func getMeshRenderers() -> [MeshRenderer] {
        var renderers = [MeshRenderer]()
        
        for entity in entities {
            for component in entity.components {
                if let renderer = component as? MeshRenderer {
                    renderers.append(renderer)
                }
            }
        }
        
        return renderers
    }
    
    // MARK: - Private API
    
}
