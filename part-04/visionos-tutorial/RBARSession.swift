//
//  RBARSession.swift
//  Session and provider handling for ARKit
//
//  Created by Roger Boesch on 01/01/2024.
//  Copyright © 2024 Roger Boesch. All rights reserved.
//

import Foundation
import ARKit
import RealityKit
import SwiftUI

@MainActor
protocol RBARSystem {
    // Properties
    var isProviderSupported: Bool { get }
    var provider: DataProvider { get }
    var isReadyToRun: Bool { get }
    
    // Functions
    func attachToNode(_ node: Entity, content: RealityViewContent)
    func setup()
    func startTracking() async;
}

@MainActor
class RBARSession {
    private static var INSTANCE: RBARSession? = nil
    private var _session = ARKitSession()
    private var _providers: [DataProvider] = []
    private var _errorState = false                     // Must be changed to later to track errors by each provider

    static var instance: RBARSession {
        get {
            if RBARSession.INSTANCE == nil {
                RBARSession.INSTANCE = RBARSession()
            }
            
            return RBARSession.INSTANCE!
        }
    }

    func startSession(systems: [RBARSystem]) {
#if !os(visionOS) && !targetEnvironment(simulator)
        rbWarning("RBARSystem just works on VisionPro device")
        return
#endif
        
        _providers.removeAll()
        
        for system in systems {
            if system.isProviderSupported && system.isReadyToRun {
                _providers.append(system.provider)
            }
        }
        
        if _providers.count == 0 {
            rbWarning("No RBARSystems found that are ready to run")
        }
        Task {
            rbInfo("Start RBAASystem(s)")
            try await _session.run(_providers)
        }
        
        Task {
            await self.monitorSessionEvents()
        }

        for system in systems {
            Task {
                await system.startTracking()
            }
        }
    }
    
    // Responds to events like authorization revocation.
    private func monitorSessionEvents() async {
        for await event in _session.events {
            switch event {
            case .authorizationChanged(type: _, status: let status):
                rbInfo("Authorization changed to: \(status)")
                
                if status == .denied {
                    _errorState = true
                }
            case .dataProviderStateChanged(dataProviders: let providers, newState: let state, error: let error):
                rbInfo("Data provider changed: \(providers), \(state)")
                
                if let error {
                    rbError("Data provider reached an error state: \(error)")
                    _errorState = true
                }
            @unknown default:
                rbError("Unhandled new event type \(event)")
            }
        }
    }

}
