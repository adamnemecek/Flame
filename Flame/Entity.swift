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
    var matrix = float4x4.identity()
}
