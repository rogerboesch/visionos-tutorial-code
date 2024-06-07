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

@Observable class RBHeadPose {
    private static var INSTANCE: RBHeadPose? = nil
    
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    var matrix = simd_float4x4()

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
            pos.x = matrix.columns.3.x
            pos.y = matrix.columns.3.y
            pos.z = matrix.columns.3.z

            return pos
        }
    }

    func runArSession() {
        rbInfo("Start head pose session");

        Task {
            do {
                try? await session.run([worldTracking])
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task {
                guard let matrix = await self.getMatrix() else { return }
                self.matrix = matrix
                
                rbTrace("Updated position is: \(self.position)")
            }
        }
    }

    private func getMatrix() async -> simd_float4x4? {
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        else {
            rbWarning("Can't get device anchor");
            return nil
        }
    
        let transform = deviceAnchor.originFromAnchorTransform
        
        rbTrace("Device: \(transform)")

        return transform
    }
}
