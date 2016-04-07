//
//  Shaders.metal
//  Flame
//
//  Created by Kenny Deriemaeker on 27/03/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

#include <metal_stdlib>
#include <metal_matrix>

using namespace metal;

struct Uniforms
{
    float4x4 modelViewProjectionMatrix;
};

struct Vertex
{
    float4 position [[position]];
    float4 color;
};

struct ProjectedVertex
{
    float4 position [[position]];
    float4 color;
};

// Vertex shader
vertex ProjectedVertex vertex_main(constant Vertex *vertices [[buffer(0)]],
                                 constant Uniforms &uniforms [[buffer(1)]],
                                 uint vertexID [[vertex_id]])
{
    ProjectedVertex vert;
    
    vert.position = uniforms.modelViewProjectionMatrix * vertices[vertexID].position;
    vert.color = vertices[vertexID].color;
    
    return vert;
}

// Fragment shader
fragment float4 fragment_main(ProjectedVertex vert [[stage_in]])
{
    return vert.color;
}