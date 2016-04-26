//
//  Camera.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 11/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import Foundation

class Camera : Component {
    
    var fov: Float
    var near: Float
    var far: Float
    var aspect: Float
    
    var viewMatrix: Matrix4 {
        guard let entity = entity else { return Matrix4.Identity }
        
        return Matrix4(rotation: Vector4(1, 0, 0, -entity.transform.rotation.x))
            * Matrix4(rotation: Vector4(0, 1, 0, -entity.transform.rotation.y))
            * Matrix4(rotation: Vector4(0, 0, 1, -entity.transform.rotation.z))
            * Matrix4(translation: -entity.transform.position)
    }
    
    var projectionMatrix: Matrix4 {
        return Matrix4(fovx: fov * Scalar.RadiansPerDegree, aspect: aspect, near: near, far: far)
    }
    
    required init() {
        fov = 90
        near = 0.1
        far = 256.0
        aspect = 0.75
        
        super.init()
    }
    
    override func update(seconds: NSTimeInterval) {
        guard let entity = entity else { return }
        let speed: Float = 2.0 * Float(seconds)
        
        let viewMatrix = self.viewMatrix.toArray()
        
        let up = Vector3(viewMatrix[1], viewMatrix[5], viewMatrix[9])
        let forward = Vector3(viewMatrix[2], viewMatrix[6], viewMatrix[10])
        let right = Vector3(viewMatrix[0], viewMatrix[4], viewMatrix[8])

        if Input.sharedInstance.isKeyDown(0) {
            entity.transform.position = entity.transform.position - (right * speed)
        }
        
        if Input.sharedInstance.isKeyDown(2) {
            entity.transform.position = entity.transform.position + (right * speed)
        }

        if Input.sharedInstance.isKeyDown(13) {
            entity.transform.position = entity.transform.position - (forward * speed)
        }
        
        if Input.sharedInstance.isKeyDown(1) {
            entity.transform.position = entity.transform.position + (forward * speed)
        }

        if Input.sharedInstance.isKeyDown(49) {
            entity.transform.position = entity.transform.position + (up * speed)
        }

        if Input.sharedInstance.isKeyDown(8) {
            entity.transform.position = entity.transform.position - (up * speed)
        }

        if Input.sharedInstance.isKeyDown(124) {
            entity.transform.rotation.y -= speed
        }

        if Input.sharedInstance.isKeyDown(123) {
            entity.transform.rotation.y += speed
        }

    }
    
}
