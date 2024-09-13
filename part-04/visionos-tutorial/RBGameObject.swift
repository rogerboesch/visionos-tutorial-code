//
//  RBGameObject.swift
//  Extends RBGameObject for this game specific things
//
//  Created by Roger Boesch on 01/01/2024.
//  Copyright © 2024 Roger Boesch. All rights reserved.
//

import Foundation
import RealityKit
import SwiftUI
import UIKit

class RBGameObject {
    static let DEFAULT_VELOCITY: Float = 0.2                    // Default velocity

    private static var _counter = 0
    private var _uniqueID = 0
    private var _tag = 0
    private var _entity: Entity?
    private var _scale: Float = 1.0
    private var _position = SIMD3<Float>(0, 0, 0)
    private var _rotation = SIMD3<Float>(0, 0, 0)
    private var _velocity: Float = 0
    private var _angle: Float = 0
    private var _isActive = true
    
    var id: Int {
        get {
            return _uniqueID
        }
    }

    var tag: Int {
        get {
            return _tag
        }
        set(value) {
            _tag = value
        }
    }

    var isActive: Bool {
        get {
            return _isActive
        }
        set(value) {
            _isActive = value
            
            _entity?.isEnabled = _isActive
        }
    }

    var velocity: Float {
        get {
            return _velocity
        }
        set(value) {
            _velocity = value
        }
    }

    var angle: Float {
        get {
            return _angle
        }
        set(value) {
            _angle = value
        }
    }

    var position: SIMD3<Float> {
        get {
            return _position
        }
        set(value) {
            _position = value
            
            if _entity != nil {
                _entity?.position = _position
            }
        }
    }
    
    private var rotation: SIMD3<Float> {
        get {
            return _rotation
        }
        set(value) {
            _rotation = value

            if _entity != nil {
                // Node works with DEG, SceneKit with RAD
                let x = RBMath.degreesToRadians(_rotation.x)
                let y = RBMath.degreesToRadians(_rotation.y)
                let z = RBMath.degreesToRadians(_rotation.z)
                
                let rotationQuaternionX = simd_quatf(angle: x, axis: SIMD3<Float>(1, 0, 0))
                let rotationQuaternionY = simd_quatf(angle: y, axis: SIMD3<Float>(0, 1, 0))
                let rotationQuaternionZ = simd_quatf(angle: z, axis: SIMD3<Float>(0, 0, 1))

                _entity?.transform.rotation = rotationQuaternionX * rotationQuaternionY * rotationQuaternionZ
            }
        }
    }

    var scale: Float {
        get {
            return _scale
        }
        set(value) {
            _scale = value
            
            if _entity != nil {
                _entity?.transform.scale = [_scale, _scale, _scale]
            }
        }
    }

    var entity: Entity? {
        get {
            return _entity
        }
        set(value) {
            _entity = value
        }
    }
    
    public func changeDirection(to angle: Float) {
        _angle = angle
    }
    
    public func changeDirection(by angle: Float) {
        _angle += angle
    }

    public func removeFromScene() {
        _entity?.removeFromParent()
        _entity = nil
        rbDebug("Game object '\(self.id)' removed from scene")
    }

    public func reset() {
        self.isActive = true
    }

    internal func update(deltaTime: Float) {
        let speedX = _velocity * deltaTime
        let speedY = _velocity * deltaTime
        let dx = cos(RBMath.degreesToRadians(_angle))
        let dy = sin(RBMath.degreesToRadians(_angle))
        self.position.x += speedX * dx
        self.position.z += speedY * dy
        
        var rotation = self.rotation
        rotation.y = -1.0 *  (_angle - 90.0)
        self.rotation = rotation
    }
    
    func fly() {
        self.velocity = RBGameObject.DEFAULT_VELOCITY
        changeDirection(to: -90.0)
    }

    init() {
        RBGameObject._counter = RBGameObject._counter + 1
        _uniqueID = RBGameObject._counter
        
        self.rotation = [0, 90, 0]
    }

    init(entity: Entity) {
        RBGameObject._counter = RBGameObject._counter + 1
        _uniqueID = RBGameObject._counter
        
        self.rotation = [0, 90, 0]

        _entity = entity
    }
}

