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

    @EnvironmentObject var settings: GameSettings

    @State private var airplane: Entity? = nil
    
    @State private var placeRing: Entity? = nil
    @State private var ringAnchor: AnchorEntity? = nil
    @State private var realityContent: RealityViewContent? = nil
    @State private var currentPosition: SIMD3<Float>? = nil
    @State private var counter = 0

    var body: some View {
        RealityView { content, attachments in
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(scene)
                realityContent = content

                ringAnchor = AnchorEntity(.head)
                ringAnchor?.position = [0, 0, -1]
                content.add(ringAnchor!)

                placeRing = createRing(color: .lightGray)
                placeRing?.isEnabled = false
                ringAnchor?.addChild(placeRing!)

                guard let attachment = attachments.entity(for: "ring_attachment") else { return }
                attachment.position = SIMD3<Float>(0, -0.05, 0)
                ringAnchor?.addChild(attachment)
                
                if let model = scene.findEntity(named: "ToyBiplane") as Entity? {
                    airplane = model
                    airplane?.isEnabled = true
                    let radians = 180.0 * Float.pi / 180.0
                    airplane?.transform.rotation = simd_quatf(angle: radians,
                                                              axis: SIMD3<Float>(0,1,0))
                }

                RBHeadPose.instance.runArSession()
            }
        }
    attachments: {
        Attachment(id: "ring_attachment") {
            Button(action: {
                placeObjectAtHeadPose()
            }) {
                if settings.state == .placeAircraft {
                    Text("Press Button To Place Airplane")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
                else {
                    Text("Press Button To Place Ring")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
            }
            .padding()
            .buttonStyle(.bordered)
        }
    }
    }
    
    private func placeObjectAtHeadPose() {
        if settings.state == .placeAircraft {
            placeAirplaneAtHeadPose()
        }
        else {
            placeRingAtHeadPose()
        }
    }
    
    private func placeAirplaneAtHeadPose() {
        guard let airplane = airplane else { return }
        
        var position = RBHeadPose.instance.position

        // Adjust z position, so it is at same place as place "ring"
        position.z = position.z - 1

        // Show airplane
        airplane.position = position
        airplane.isEnabled = true
        
        // Change state
        settings.state = .placeRings
        placeRing?.isEnabled = true
    }

    private func placeRingAtHeadPose() {
        guard let content = realityContent else { return }

        // This is the ring number
        counter = counter + 1
        
        var position = RBHeadPose.instance.position

        // Adjust z position, so it is at same place as place "ring"
        position.z = position.z - 1

        // Create Anchor
        let anchorEntity = AnchorEntity(world: position)
        let ring = createRing(color: .red)
        anchorEntity.addChild(ring)
        content.add(anchorEntity)

        // Add Ring number
        let text = ModelEntity(mesh: .generateText("\(counter)", extrusionDepth: 0,
                                                   font: .boldSystemFont(ofSize: 0.06)))
        text.model?.materials = [UnlitMaterial()]
        let offset = text.visualBounds(relativeTo: nil).extents.x / 2
        text.position.x = -offset
        text.position.y = 0.0
        anchorEntity.addChild(text)
    }
    
    private func createRing(color: UIColor) -> ModelEntity {
        let meshResource: MeshResource = try! RBTorus.generate(segments: 128,
                                                               tubeSegments: 32,
                                                               radius: 0.2,
                                                               tubeRadius: 0.01)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let ring = ModelEntity(mesh: meshResource, materials: [material])

        return ring
    }

}
