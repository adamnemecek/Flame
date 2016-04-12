//
//  Entity.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 3/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import GameplayKit

class Entity : GKEntity {
    
    var name: String = "UnnamedEntity"
    var transform: Transform
    
    override init() {
        self.transform = Transform()
        super.init()
    }
    
}

class Transform : GKComponent {
    
    var position: float3
    var rotation: float3
    var scale: float3
    
    var modelMatrix: float4x4 {
        return float4x4
            .makeScale(scale.x, scale.y, scale.z)
            .translate(position.x, position.y, position.z)
            .rotate(rotation.x, 1, 0, 0)
            .rotate(rotation.y, 0, 1, 0)
            .rotate(rotation.z, 0, 0, 1)
    }
    
    override init() {
        position = float3(0, 0, 0)
        rotation = float3(0, 0, 0)
        scale = float3(1, 1, 1)
        super.init()
    }
    
}
