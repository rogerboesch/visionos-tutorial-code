//
//  RBHeadPose.swift
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

import SwiftUI
import RealityKit
import ARKit

@Observable
class RBHeadPose : RBARSystem {
    private static var INSTANCE: RBHeadPose? = nil
    
    let _worldTracking = WorldTrackingProvider()
    var _transform = simd_float4x4()

    static var instance: RBHeadPose {
        get {
            if RBHeadPose.INSTANCE == nil {
                RBHeadPose.INSTANCE = RBHeadPose()
            }
            
            return RBHeadPose.INSTANCE!
        }
    }
    
    var position: SIMD3<Float> {
        get {
            var pos = SIMD3<Float>()
            pos.x = _transform.columns.3.x
            pos.y = _transform.columns.3.y
            pos.z = _transform.columns.3.z

            return pos
        }
    }

    var provider: DataProvider {
        get {
            return _worldTracking
        }
    }
    
    var isProviderSupported: Bool {
        WorldTrackingProvider.isSupported
    }
    
    var isReadyToRun: Bool {
        _worldTracking.state == .initialized
    }

    func attachToNode(_ node: Entity, content: RealityViewContent) {
        // Used for visualisation if needed
    }
    
    func setup() {
        // Used for setup if needed
    }
    
    func startTracking() async {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task {
                await self.updateMatrix()
            }
        }
    }

    private func updateMatrix() async {
        guard let deviceAnchor = _worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        else {
            rbWarning("Can't get device anchor");
            return
        }
    
        let transform = deviceAnchor.originFromAnchorTransform
        _transform = transform
        
        rbTrace("Device: \(transform)")
    }
}
