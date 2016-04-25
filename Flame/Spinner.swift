//
//  Spinner.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 8/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

class Spinner : Component {

    var speed: Float = 0.0
    
    required init() {
    }
    
    override func update(seconds: NSTimeInterval) {
        super.update(seconds)
        guard let entity = entity else { return }
        
        entity.transform.rotation.y += speed * Float(seconds)
    }
    
}
