//
//  RBHandTracking.swift
//  Hand tracking
//
//  Created by Roger Boesch on 01/01/2024.
//  Copyright © 2024 Roger Boesch. All rights reserved.
//

import ARKit
import RealityKit
import UIKit
import SwiftUI

typealias HandTrackingCallBack = (RBHandTracking.HandInfo, RBHandTracking.HandInfo) -> ()
typealias HandTrackingObjectCallBack = (RBHandTracking.HandInfo, String) -> ()
typealias HandTrackingFollowCallBack = (RBHandTracking.HandInfo) -> ()
typealias HandTrackingGestureCallBack = (RBHandTracking.Gesture, Pose3D) -> ()

@Observable
@MainActor
class RBHandTracking : RBARSystem {
    enum State {
        case none
        case active
        case inactive
    }
    
    enum Gesture {
        case heart
    }

    struct HandInfo {
        var chirality: HandAnchor.Chirality
        var joint: HandSkeleton.JointName
        var model: ModelEntity
        var follow: Bool
    }
    
    var onJointCollision: HandTrackingCallBack?
    var onJointObjectCollision: HandTrackingObjectCallBack?
    var onJointFollowCallBack: HandTrackingFollowCallBack?
    var onGestureCallBack: HandTrackingGestureCallBack?

    let handTracking = HandTrackingProvider()
    
    private var _trackingState = State.none
    
    private var _parentNode: Entity?
    private var _content: RealityViewContent?
    
    private var _contentEntity = Entity()
    
    private var _leftHandEntities: [HandSkeleton.JointName:HandInfo] = [:]
    private var _rightHandEntities: [HandSkeleton.JointName:HandInfo] = [:]
    private var _handEntities: [String:HandInfo] = [:]
    
    private var leftHand: HandAnchor?
    private var rightHand: HandAnchor?
    
    private var _lastNameA = ""
    private var _lastNameB = ""
    
    init() {
        rbDebug("RBHandTracking initialized")
    }
    
    var state: State {
        get {
            return _trackingState
        }
    }
    
    var provider: DataProvider {
        get {
            return handTracking
        }
    }
    
    var isProviderSupported: Bool {
        HandTrackingProvider.isSupported
    }
    
    var isReadyToRun: Bool {
        handTracking.state == .initialized
    }
    
    func getHandInfo(name: String) -> HandInfo? {
        return _handEntities[name]
    }
    
    // MARK: Collision handling
    
    func handleCollision(nameA: String, nameB: String) {
        if _trackingState != .active {
            return
        }
        
        // Check if previous call was opposite
        if nameA == _lastNameB && nameB == _lastNameA {
            return
        }
        
        if let infoA = _handEntities[nameA],  let infoB = _handEntities[nameB] {
            // Collision between joints
            onJointCollision?(infoA, infoB)
        }
        else if let infoA = _handEntities[nameA] {
            // Collision between joint and other object
            onJointObjectCollision?(infoA, nameB)
        }
        else if let infoB = _handEntities[nameB] {
            // Collision between joint and other object
            onJointObjectCollision?(infoB, nameA)
        }
        
        _lastNameA = nameA
        _lastNameB = nameB
    }
    
    // MARK: Set joints to track
    
    func activateTracking(chirality: HandAnchor.Chirality, joint: HandSkeleton.JointName, follow: Bool = false) {
        if _parentNode == nil || _content == nil {
            rbWarning("Handtracking nodes are not attached to parent. Use attachToNode() before call activateTracking()")
            return
        }
        
        var modelEntity: ModelEntity? = nil
        
        if joint == .forearmWrist {
            let mesh = MeshResource.generateBox(size: 0.06)
            let material = SimpleMaterial(color: UIColor.green, isMetallic: false)
            modelEntity = ModelEntity(mesh: mesh, materials: [material])
            
            let bounds =  mesh.bounds.extents
            modelEntity?.components.set(CollisionComponent(shapes: [.generateBox(size: bounds)]))
        }
        else {
            let mesh = MeshResource.generateSphere(radius: 0.01)
            let material = SimpleMaterial(color: UIColor.red, isMetallic: false)
            modelEntity = ModelEntity(mesh: mesh, materials: [material])
            
            let bounds =  mesh.bounds.extents
            modelEntity?.components.set(CollisionComponent(shapes: [.generateBox(size: bounds)]))
        }
        
        guard let entity = modelEntity else {
            rbFatal("Model entity not created for Hand-tracking. STOP")
            return
        }
        
        let key = "\(chirality)-\(joint)"
        entity.name = key
        
        
        // Disable to make it visible
        //entity.components.set(OpacityComponent(opacity: 0.0))
        
        // Add to parent
        _contentEntity.addChild(entity)
        
        // Create info
        let info = HandInfo(chirality: chirality, joint: joint, model: entity, follow: follow)
        
        // Add to map
        if chirality == .left {
            _leftHandEntities[joint] = info
        }
        else {
            _rightHandEntities[joint] = info
        }
        
        // Add to info map
        _handEntities[key] = info
        
        // Subscribe for collisions
        let _ = _content!.subscribe(to: CollisionEvents.Began.self, on: entity) { ce in
            self.handleCollision(nameA: ce.entityA.name, nameB: ce.entityB.name)
        }
    }
    
    func attachToNode(_ node: Entity, content: RealityViewContent) {
        _parentNode = node
        _content = content
        
        _parentNode?.addChild(_contentEntity)
    }
    
    func setup() {
        // Does just some checks
        if _parentNode == nil || _content == nil {
            rbWarning("Handtracking nodes are not attached to parent. Use attachToNode() before call start()")
            return
        }
        
        if _handEntities.isEmpty {
            rbWarning("Add some joints for tracking by using activateTracking() first ")
            return
        }
    }
    
    func startTracking() async {
        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            if handAnchor.isTracked {
                _trackingState = .inactive
                processHandJoints(handAnchor: handAnchor)
            }
            else {
                rbTrace("Hand anchor NOT tracked")
                _trackingState = .inactive
            }
        }
    }
    
    func processHandJoints(handAnchor: HandAnchor) {
        if handAnchor.chirality == .left {
            leftHand = handAnchor
            
            for key in _leftHandEntities.keys {
                if let joint = handAnchor.handSkeleton?.joint(key), joint.isTracked {
                    let originFromJoint = handAnchor.originFromAnchorTransform * joint.anchorFromJointTransform
                    _leftHandEntities[key]?.model.setTransformMatrix(originFromJoint, relativeTo: nil)
                    
                    if _leftHandEntities[key]!.follow {
                        onJointFollowCallBack?(_leftHandEntities[key]!)
                    }
                    
                    _trackingState = .active
                }
            }
        }
        
        if handAnchor.chirality == .right {
            rightHand = handAnchor
            
            for key in _rightHandEntities.keys {
                if let joint = handAnchor.handSkeleton?.joint(key), joint.isTracked {
                    let originFromJoint = handAnchor.originFromAnchorTransform * joint.anchorFromJointTransform
                    _rightHandEntities[key]?.model.setTransformMatrix(originFromJoint, relativeTo: nil)
                    
                    if _rightHandEntities[key]!.follow {
                        onJointFollowCallBack?(_rightHandEntities[key]!)
                    }
                    
                    _trackingState = .active
                }
            }
        }
        
        if let m = processHeartGesture(), let pose = Pose3D(m) {
            onGestureCallBack?(.heart, pose)
        }
    }

    private func processHeartGesture() -> simd_float4x4? {
        // Get the latest hand anchors, return false if either of them isn't tracked.
        guard let leftHandAnchor = leftHand, let rightHandAnchor = rightHand,
              let _ = leftHand?.isTracked,   let _ = rightHand?.isTracked else {
            return nil
        }
        
        // Get all required joints and check if they are tracked.
        guard
            let leftHandThumbKnuckle = leftHandAnchor.handSkeleton?.joint(.thumbKnuckle),
            let leftHandThumbTipPosition = leftHandAnchor.handSkeleton?.joint(.thumbTip),
            let leftHandIndexFingerTip = leftHandAnchor.handSkeleton?.joint(.indexFingerTip),
            let rightHandThumbKnuckle = rightHandAnchor.handSkeleton?.joint(.thumbKnuckle),
            let rightHandThumbTipPosition = rightHandAnchor.handSkeleton?.joint(.thumbTip),
            let rightHandIndexFingerTip = rightHandAnchor.handSkeleton?.joint(.indexFingerTip),
            leftHandIndexFingerTip.isTracked && leftHandThumbTipPosition.isTracked &&
            rightHandIndexFingerTip.isTracked && rightHandThumbTipPosition.isTracked &&
            leftHandThumbKnuckle.isTracked && rightHandThumbKnuckle.isTracked
        else {
            return nil
        }
        
        // Get the position of all joints in world coordinates.
        let originFromLeftHandThumbKnuckleTransform = matrix_multiply(leftHandAnchor.originFromAnchorTransform, leftHandThumbKnuckle.anchorFromJointTransform).columns.3.xyz
        let originFromLeftHandThumbTipTransform = matrix_multiply(leftHandAnchor.originFromAnchorTransform, leftHandThumbTipPosition.anchorFromJointTransform).columns.3.xyz
        let originFromLeftHandIndexFingerTipTransform = matrix_multiply(leftHandAnchor.originFromAnchorTransform, leftHandIndexFingerTip.anchorFromJointTransform).columns.3.xyz
        let originFromRightHandThumbKnuckleTransform = matrix_multiply(rightHandAnchor.originFromAnchorTransform, rightHandThumbKnuckle.anchorFromJointTransform).columns.3.xyz
        let originFromRightHandThumbTipTransform = matrix_multiply(rightHandAnchor.originFromAnchorTransform, rightHandThumbTipPosition.anchorFromJointTransform).columns.3.xyz
        let originFromRightHandIndexFingerTipTransform = matrix_multiply(rightHandAnchor.originFromAnchorTransform, rightHandIndexFingerTip.anchorFromJointTransform).columns.3.xyz
        
        let indexFingersDistance = distance(originFromLeftHandIndexFingerTipTransform, originFromRightHandIndexFingerTipTransform)
        let thumbsDistance = distance(originFromLeftHandThumbTipTransform, originFromRightHandThumbTipTransform)
        
        // Heart gesture detection is true when the distance between the index finger tips centers
        // and the distance between the thumb tip centers is each less than four centimeters.
        let isHeartShapeGesture = indexFingersDistance < 0.04 && thumbsDistance < 0.04
        if !isHeartShapeGesture {
            return nil
        }
        
        // Compute a position in the middle of the heart gesture.
        let halfway = (originFromRightHandIndexFingerTipTransform - originFromLeftHandThumbTipTransform) / 2
        let heartMidpoint = originFromRightHandIndexFingerTipTransform - halfway
        
        // Compute the vector from left thumb knuckle to right thumb knuckle and normalize (X axis).
        let xAxis = normalize(originFromRightHandThumbKnuckleTransform - originFromLeftHandThumbKnuckleTransform)
        
        // Compute the vector from right thumb tip to right index finger tip and normalize (Y axis).
        let yAxis = normalize(originFromRightHandIndexFingerTipTransform - originFromRightHandThumbTipTransform)
        
        let zAxis = normalize(cross(xAxis, yAxis))
        
        // Create the final transform for the heart gesture from the three axes and midpoint vector.
        let heartMidpointWorldTransform = simd_matrix(
            SIMD4(xAxis.x, xAxis.y, xAxis.z, 0),
            SIMD4(yAxis.x, yAxis.y, yAxis.z, 0),
            SIMD4(zAxis.x, zAxis.y, zAxis.z, 0),
            SIMD4(heartMidpoint.x, heartMidpoint.y, heartMidpoint.z, 1)
        )
        
        return heartMidpointWorldTransform

    }
}
