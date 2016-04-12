//
//  Spinner.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 8/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import GameplayKit
import simd

class Spinner : GKComponent {

    var speed: Float = 0.0
    
    init(speed: Float) {
        self.speed = speed
        super.init()
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        if let owner = entity as? Entity {
            owner.transform.rotation.y += speed * Float(seconds)
        }
        
    }
    
}
