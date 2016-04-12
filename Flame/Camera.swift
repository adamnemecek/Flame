//
//  Camera.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 11/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import GameplayKit
import simd

class Camera : GKComponent {
    
    var fov: Float
    var near: Float
    var far: Float
    var aspect: Float
    
    var viewMatrix: float4x4 {
        guard let owner = self.entity as? Entity else { return float4x4.identity() }
        
        return float4x4.identity()
            .rotate(-owner.transform.rotation.x, 1, 0, 0)
            .rotate(-owner.transform.rotation.y, 0, 1, 0)
            .rotate(-owner.transform.rotation.z, 0, 0, 1)
            .translate(-owner.transform.position.x, -owner.transform.position.y, -owner.transform.position.z)
    }
    
    var projectionMatrix: float4x4 {
        return float4x4.makePerspective(fov, aspect, near, far)
    }
    
    override init() {
        fov = 20.0
        near = 0.1
        far = 256.0
        aspect = 0.75
        
        super.init()
    }
    
}
