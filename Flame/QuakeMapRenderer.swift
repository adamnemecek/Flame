//
//  QuakeMapRenderer.swift
//  Flame
//
//  Created by Kenny Deriemaeker on 15/05/16.
//  Copyright © 2016 Kenny Deriemaeker. All rights reserved.
//

import MetalKit

class QuakeMapRenderer : MeshRenderer {

    var drawWireframe = true
    
    var wireVertexBuffer: MTLBuffer?
    var wireVertexCount: Int = 0
    
    var bsp: QuakeBSP? {
        didSet {
            generateBuffers()
        }
    }
    
    private var vertexCount = 0
    
    override func generateBuffers() {
        guard let bsp = bsp else { return }
        
        let device = Renderer.sharedInstance.device
        
        var vertices = [Vertex]()
        
        // vertices.append(Vertex(position: Vector4(v0.x, v0.z, -v0.y, 1), color: defaultColor))
        
        for face in bsp.faces {

            // Look up list of face edges and extract vertices.
            var faceVertices = [BSPVertex]()

            for f in 0 ..< face.edgeCount {
                let faceEdgeIndex = face.firstEdgeIndex + f
                let edgeIndex = bsp.edgeList[faceEdgeIndex].edgeIndex
                
                //print("e \(edgeIndex)")
                
                var vertexIndex = 0
                
                // A negative index into the edge list indicates the edge needs to be
                // inverted for this face (end vertex to start vertex).
                if edgeIndex < 0 {
                    vertexIndex = bsp.edges[abs(edgeIndex)].startVertexIndex
                }
                else {
                    vertexIndex = bsp.edges[edgeIndex].endVertexIndex
                }
                
                //print("e \(edgeIndex) -> v \(vertexIndex)")

                faceVertices.append(bsp.vertices[vertexIndex])
            }
            
            // Assemble triangles and add to vertex buffer.
            var indices = [Int](count: (face.edgeCount - 2) * 3, repeatedValue: 0)
            var triangleStep = 1
            for i in 1 ..< faceVertices.count - 1 {
                indices[triangleStep - 1] = 0
                indices[triangleStep] = i
                indices[triangleStep + 1] = i + 1
                triangleStep += 3
            }
            
            var colorStepper = 0
            for index in indices {
                
                let v = faceVertices[index]
                
                var vertColor = Vector4(0.9, 0.9, 0.9, 1)
                if colorStepper == 1 {
                    vertColor = Vector4(0.85, 0.85, 0.85, 1)
                }
                if colorStepper == 2 {
                    vertColor = Vector4(0.8, 0.8, 0.8, 1)
                }

                vertices.append(Vertex(position: Vector4(v.position.toVector3(), 1), color: vertColor))
                
                colorStepper += 1
                if colorStepper > 2 {
                    colorStepper = 0
                }
            }
            
        }

        vertexCount = vertices.count
        vertexBuffer = device.newBufferWithBytes(vertices,
            length: vertices.count * sizeof(Vertex),
            options: .CPUCacheModeDefaultCache)

        var wireVertices = [Vertex]()
        
        for edge in bsp.edges {
            wireVertices.append(Vertex(position: Vector4(bsp.vertices[edge.startVertexIndex].position.toVector3(), 1),
                color: Vector4(0.1, 0.1, 0.1, 1)))
            
            wireVertices.append(Vertex(position: Vector4(bsp.vertices[edge.endVertexIndex].position.toVector3(), 1),
                color: Vector4(0.1, 0.1, 0.1, 1)))
        }
        
        wireVertexCount = wireVertices.count
        
        wireVertexBuffer = device.newBufferWithBytes(wireVertices,
            length: wireVertexCount * sizeof(Vertex),
            options: .CPUCacheModeDefaultCache)
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder) {
        if drawWireframe {
            commandEncoder.setVertexBuffer(wireVertexBuffer, offset: 0, atIndex: 0)
            commandEncoder.drawPrimitives(.Line, vertexStart: 0, vertexCount: wireVertexCount, instanceCount: 1)
        }

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
    }
    
}
