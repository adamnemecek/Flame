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

    // MARK: - Init & deinit
    
    func setup() {
        let triangle = Entity()
        triangle.name = "Triangle"
        triangle.addComponent(TriangleRenderer())
        entities.append(triangle)
        
        let triangle2 = Entity()
        triangle2.name = "Triangle2"
        triangle2.addComponent(TriangleRenderer(color1: float3(0, 1, 1), color2: float3(1, 0, 1), color3: float3(1, 1, 0)))
        triangle2.transform.matrix = float4x4.makeTranslation(0.5, 0, -0.3).rotate(0.5, 0, 1, 0)
        entities.append(triangle2)
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
