//
//  RBMath.swift
//
//  Vision OS - From Zero to Hero
//  This code was written as part of a tutorial at https://visionos.substack.com
//
//  Created by Roger Boesch on 01/01/2024.
//
//  DISCLAIMER:
//  The intention of this tutorial is not to always write the best possible code but
//  to show different ways to create a game or app that even can be published.
//  I will also refactor a lot during the tutorial and improve things step by step
//  or even show completely different approaches.
//
//  Feel free to use the code in the way you want :)
//

import Foundation
import RealityKit

struct RBMath {
    
    // MARK: - Angle, rotation & distance
    
    static func rotateX(_ x: Float) -> simd_quatf {
        let xx = RBMath.degreesToRadians(x)

        let rotationQuaternionX = simd_quatf(angle: xx, axis: SIMD3<Float>(1, 0, 0))
        return rotationQuaternionX
    }
    
    static func rotateY(_ y: Float) -> simd_quatf {
        let yy = RBMath.degreesToRadians(y)

        let rotationQuaternionY = simd_quatf(angle: yy, axis: SIMD3<Float>(0, 1, 0))
        return rotationQuaternionY
    }
    
    static func rotateZ(_ z: Float) -> simd_quatf {
        let zz = RBMath.degreesToRadians(z)

        let rotationQuaternionZ = simd_quatf(angle: zz, axis: SIMD3<Float>(0, 0, 1))
        return rotationQuaternionZ
    }

    static func rotate(x: Float, y: Float, z: Float) -> simd_quatf {
        let xx = RBMath.degreesToRadians(x)
        let yy = RBMath.degreesToRadians(y)
        let zz = RBMath.degreesToRadians(z)

        let rotationQuaternionX = simd_quatf(angle: xx, axis: SIMD3<Float>(1, 0, 0))
        let rotationQuaternionY = simd_quatf(angle: yy, axis: SIMD3<Float>(0, 1, 0))
        let rotationQuaternionZ = simd_quatf(angle: zz, axis: SIMD3<Float>(0, 0, 1))

        let rotation = rotationQuaternionX * rotationQuaternionY * rotationQuaternionZ
        
        return rotation
    }

    static func angleBetweenPoints(x1: Float, y1: Float, x2: Float, y2: Float) -> Float {
        let xDiff = x2 - x1
        let yDiff = y2 - y1
        
        return atan2(yDiff, xDiff) * 180.0 / Float.pi
    }
    
    static func distance(x1: Float, y1: Float, x2: Float, y2: Float) ->Float {
        let dist = hypotf((x1-x2), (y1-y2));
        return dist
    }

    // MARK: - RAD/DEG
    
    static func degreesToRadians(_ value: Float) -> Float {
        return value * Float.pi / 180.0
    }
    
    static func radiansToegrees(_ value: Float) -> Float {
        return value * 180.0 / Float.pi
    }

    // MARK: - Random functions
    
    static func random(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    static func random01f() -> Float {
        let rnd = Float(RBMath.random(min: 0, max: 10))
        let result = rnd * 0.1
        
        return result
    }
    
    static func randomTrueFalse() -> Bool {
        let rnd = RBMath.random(min: 0, max: 1)
        if (rnd == 1) {
            return true
        }
        
        return false
    }
    
    static func randomPlusMinus() -> Float {
        let rnd = RBMath.random(min: 0, max: 1)
        if (rnd == 1) {
            return 1.0
        }
        
        return -1.0
    }
}
