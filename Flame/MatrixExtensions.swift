//
//  MatrixExtensions.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 4/04/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import simd
import GLKit

extension float4x4 {
    
    static func identity() -> float4x4 {
        return float4x4(diagonal: float4(1, 1, 1, 1))
    }
    
    static func makeScale(x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeScale(x, y, z), float4x4.self)
    }
    
    static func makeRotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeRotation(radians, x, y, z), float4x4.self)
    }
    
    static func makeTranslation(x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeTranslation(x, y, z), float4x4.self)
    }
    
    static func makePerspective(fovyRadians: Float, _ aspect: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakePerspective(fovyRadians, aspect, nearZ, farZ), float4x4.self)
    }
    
    static func makeFrustum(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeFrustum(left, right, bottom, top, nearZ, farZ), float4x4.self)
    }
    
    static func makeOrtho(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeOrtho(left, right, bottom, top, nearZ, farZ), float4x4.self)
    }
    
    static func makeLookAt(eyeX: Float, _ eyeY: Float, _ eyeZ: Float, _ centerX: Float, _ centerY: Float, _ centerZ: Float, _ upX: Float, _ upY: Float, _ upZ: Float) -> float4x4 {
        return unsafeBitCast(GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ), float4x4.self)
    }
    
    func scale(x: Float, y: Float, z: Float) -> float4x4 {
        return self * float4x4.makeScale(x, y, z)
    }
    
    func rotate(radians: Float, _ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return self * float4x4.makeRotate(radians, x, y, z)
    }
    
    func translate(x: Float, _ y: Float, _ z: Float) -> float4x4 {
        return self * float4x4.makeTranslation(x, y, z)
    }
 
    func decompose() -> [Float] {
        var result = [Float]()
        
        result.append(cmatrix.columns.0.x)
        result.append(cmatrix.columns.0.y)
        result.append(cmatrix.columns.0.z)
        result.append(cmatrix.columns.0.w)
 
        result.append(cmatrix.columns.1.x)
        result.append(cmatrix.columns.1.y)
        result.append(cmatrix.columns.1.z)
        result.append(cmatrix.columns.1.w)
 
        result.append(cmatrix.columns.2.x)
        result.append(cmatrix.columns.2.y)
        result.append(cmatrix.columns.2.z)
        result.append(cmatrix.columns.2.w)
 
        result.append(cmatrix.columns.3.x)
        result.append(cmatrix.columns.3.y)
        result.append(cmatrix.columns.3.z)
        result.append(cmatrix.columns.3.w)
        
        return result
    }

}