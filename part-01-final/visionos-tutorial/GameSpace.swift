//
//  GameSpace.swift
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
import RealityKitContent

struct GameSpace: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @State var ringAnchor: AnchorEntity?
    
    var body: some View {
        RealityView { content, attachments in
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(scene)
                
                // 1. Add a head anchor to the content
                ringAnchor = AnchorEntity(.head)
                ringAnchor?.position = [0, 0, -1]
                content.add(ringAnchor!)

                // 2. Add a little box, so we can see the position
                let box = MeshResource.generateBox(size: 0.03)
                let material = SimpleMaterial(color: UIColor.red, isMetallic: true)
                let boxEntity = ModelEntity(mesh: box, materials: [material])
                ringAnchor?.addChild(boxEntity)

                // 3. Add a view (attachment)
                guard let attachment = attachments.entity(for: "ring_attachment") else { return }
                attachment.position = SIMD3<Float>(0, -0.05, 0)
                ringAnchor?.addChild(attachment)
            }
        }
    attachments: {
        Attachment(id: "ring_attachment") {
            Button(action: {
                // ... add action here
            }) {
                Text("PLACE RING")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .padding()
                    .cornerRadius(8)
            }
            .padding()
            .buttonStyle(.bordered)
        }
    }
    }
}
