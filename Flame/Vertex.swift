//
//  Vertex.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 4/06/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

struct Vertex {
    var position: Vector4
    var color: Vector4
    var textureCoords: Vector2
    
    init(position: Vector4, color: Vector4 = Vector4(1, 1, 1, 1), textureCoords: Vector2 = Vector2(0, 0)) {
        self.position = position
        self.color = color
        self.textureCoords = textureCoords
    }
}
