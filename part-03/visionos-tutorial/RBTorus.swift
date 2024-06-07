//
//  RBTorus.swift
//
//  Vision OS - From Zero to Hero
//  This code was written as part of a tutorial at https://visionos.substack.com
//
//  Created by Roger Boesch on 01/01/2024.
//  Based on https://github.com/maxxfrazer/RealityGeometries
//
//  DISCLAIMER:
//  The intention of this tutorial is not to always write the best possible code but
//  to show different ways to create a game or app that even can be published.
//  I will also refactor a lot during the tutorial and improve things step by step
//  or even show completely different approaches.
//
//  Feel free to use the code in the way you want :)
//

import RealityKit

public struct RBTorus {
    // Create a new torus MeshResource 🍩
    // - Parameters:
    //   - segments: Number of segments in the toroidal direction
    //   - tubeSegments: Number of segments in the poloidal direction
    //   - radius: Distance from the center of the torus to the center of the tube
    //   - tubeRadius: Radius of the tube
    // - Returns: A new torus MeshResource
    public static func generate(segments: Int, tubeSegments: Int, radius: Float, tubeRadius: Float) throws -> MeshResource {
        let allVertices = addTorusVertices(radius, tubeRadius, segments, tubeSegments)
        
        var indices: [UInt32] = []
        var i = 0
        let rowCount = segments + 1

        while i < tubeSegments {
            var j = 0
            while j < segments {
                indices.append(UInt32(i * rowCount + j))
                indices.append(UInt32(i * rowCount + j + 1))
                indices.append(UInt32((i + 1) * rowCount + j + 1))
                indices.append(UInt32((i + 1) * rowCount + j + 1))
                indices.append(UInt32((i + 1) * rowCount + j))
                indices.append(UInt32(i * rowCount + j))
                j += 1
            }

            i += 1
        }

        let meshDesc = allVertices.generateMeshDescriptor(with: indices)
        return try .generate(from: [meshDesc])
    }
    
    fileprivate static func addTorusVertices(_ radius: Float, _ csRadius: Float, _ sides: Int, _ csSides: Int) -> [RBVertex] {
        let angleIncs = 360 / Float(sides)
        let csAngleIncs = 360 / Float(csSides)
        var allVertices: [RBVertex] = []
        var currentradius: Float
        var jAngle: Float = 0
        var iAngle: Float = 0
        let dToR: Float = .pi / 180
        var zval: Float

        while jAngle <= 360 {
            currentradius = radius + (csRadius * cosf(jAngle * dToR))
            zval = csRadius * sinf(jAngle * dToR)

            let baseNorm: SIMD3<Float> = [cosf(jAngle * dToR), 0, sinf(jAngle * dToR)]
            iAngle = 0

            while iAngle <= 360 {
                let normVal = simd_quatf(angle: iAngle * dToR, axis: [0, 0, 1]).act(baseNorm)
                let vertexPos: SIMD3<Float> = [
                    currentradius * cosf(iAngle * dToR),
                    currentradius * sinf(iAngle * dToR),
                    zval
                ]

                var uv: SIMD2<Float> = [1 - iAngle / 360, 2 * jAngle / 360 - 1]
                if uv.y < 0 {
                    uv.y *= -1
                }

                allVertices.append(RBVertex(position: vertexPos, normal: normVal, uv: uv))
                iAngle += angleIncs
            }
            
            jAngle += csAngleIncs
        }
        
        return allVertices
    }
}

struct RBVertex {
    var position: SIMD3<Float>
    var normal: SIMD3<Float>
    var uv: SIMD2<Float>
}

extension Array where Element == RBVertex {
    func generateMeshDescriptor(with indices: [UInt32], materials: [UInt32] = []) -> MeshDescriptor {
        var meshDescriptor = MeshDescriptor()
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        
        for vx in self {
            positions.append(vx.position)
            normals.append(vx.normal)
            uvs.append(vx.uv)
        }
        
        meshDescriptor.positions = MeshBuffers.Positions(positions)
        meshDescriptor.normals = MeshBuffers.Normals(normals)
        meshDescriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
        meshDescriptor.primitives = .triangles(indices)
        
        if !materials.isEmpty {
            meshDescriptor.materials = MeshDescriptor.Materials.perFace(materials)
        }
        
        return meshDescriptor
    }
}

