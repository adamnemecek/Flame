//
//  MetalHelpers.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 28/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import simd

/** Decomposes a float4 into a Float array. */
func decompose(value: float4) -> [Float] {
    return [value.x, value.y, value.z, value.w]
}

/** Decomposes an array of float4 into a Float array. */
func decompose(elements: [float4]) -> [Float] {
    var result = [Float]()
    for element in elements {
        result.appendContentsOf(decompose(element))
    }
    return result
}

