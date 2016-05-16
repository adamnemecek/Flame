//
//  Transform.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 25/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

class Transform : Component {
    
    var position: Vector3
    var rotation: Vector3
    var scale: Vector3

    var matrix: Matrix4 {
        return Matrix4(translation: position)
            * Matrix4(rotation: Vector4(1, 0, 0, rotation.x))
            * Matrix4(rotation: Vector4(0, 1, 0, rotation.y))
            * Matrix4(rotation: Vector4(0, 0, 1, rotation.z))
            * Matrix4(scale: scale)
    }
    
    required init() {
        position = Vector3.Zero
        rotation = Vector3.Zero
        scale = Vector3(1, 1, 1)
        
        super.init()
    }
}
