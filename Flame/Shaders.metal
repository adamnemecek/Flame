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
    float4 position         [[ attribute(0) ]];
    float4 color            [[ attribute(1) ]];
    float2 textureCoords    [[ attribute(2) ]];
};

struct ProjectedVertex
{
    float4 position         [[position]];
    float4 color;
    float2 textureCoords;
};

constexpr sampler textureSampler(coord::normalized,
                                 address::repeat,
                                 filter::nearest);

// Vertex shader
vertex ProjectedVertex vertex_main(Vertex vert [[stage_in]],
                                 constant Uniforms &uniforms [[buffer(1)]])
{
    ProjectedVertex out;
    
    out.position = uniforms.modelViewProjectionMatrix * vert.position;
    out.color = vert.color;
    out.textureCoords = vert.textureCoords;
    
    return out;
}

// Fragment shader
fragment float4 fragment_main(ProjectedVertex vert [[stage_in]],
                              texture2d<float> diffuseTexture [[texture(0)]],
                              sampler textureSampler [[sampler(0)]])
{
    float4 textureColor = diffuseTexture.sample(textureSampler, vert.textureCoords);
    return vert.color * textureColor;
}
