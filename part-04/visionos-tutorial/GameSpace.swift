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
                    airplane = model.clone(recursive: true)
                    airplane?.isEnabled = true

                    content.add(airplane!)
                    model.isEnabled = false
                    
                    let radians = 180.0 * Float.pi / 180.0
                    airplane?.transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))

                    let gameObject = RBGameObject(entity: airplane!)
                    GameController.instance.airplane = gameObject
                }

                GameController.instance.onStateChanged = { (oldState, newState) in
                    switch (newState) {
                    case .placeAircraft:
                        ringAnchor?.isEnabled = true
                        break
                    case .placeRings:
                        ringAnchor?.isEnabled = true
                        break
                    default:
                        ringAnchor?.isEnabled = false
                        break
                    }
                }
                
                // Start tracking
                RBHeadPose.instance.setup()
                setupHandTracking(content: realityContent!)
                
                RBARSession.instance.startSession(systems: [RBHeadPose.instance, RBHandTracking.instance])
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
                    else if settings.state == .placed {
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

    // MARK: - Hand-tracking

    @MainActor
    private func setupHandTracking(content: RealityViewContent) {
        // Anchor used for hand tracking
        let node = Entity()
        node.position = [0,0,0]
        content.add(node)
        rbDebug("Created entity for hand-tracking at 0,0,0")

        // Hand-tracking functionality
        RBHandTracking.instance.attachToNode(node, content: content)

        // Activate handtracking for this joints
        RBHandTracking.instance.activateTracking(chirality: .left, joint: .indexFingerTip)
        RBHandTracking.instance.activateTracking(chirality: .left, joint: .thumbTip)

        RBHandTracking.instance.activateTracking(chirality: .right, joint: .indexFingerTip)
        RBHandTracking.instance.activateTracking(chirality: .right, joint: .thumbTip)

        RBHandTracking.instance.onJointCollision = { (infoA, infoB) in
            // A/B combination
            if infoA.chirality == .left && infoA.joint == .indexFingerTip &&
                infoB.chirality == .left && infoB.joint == .thumbTip {
                // Left index finger on left thumb
                GameController.instance.changeDirection(by: -10.0)
            }
            else if infoA.chirality == .right && infoA.joint == .indexFingerTip &&
                        infoB.chirality == .right && infoB.joint == .thumbTip {
                // Right index finger on left thumb
                GameController.instance.changeDirection(by: 10.0)
            }
            // B/A combination
            else if infoB.chirality == .left && infoB.joint == .indexFingerTip &&
                        infoA.chirality == .left && infoA.joint == .thumbTip {
                // Left index finger on left thumb
                GameController.instance.changeDirection(by: -10.0)
            }
            else if infoB.chirality == .right && infoB.joint == .indexFingerTip &&
                        infoA.chirality == .right && infoA.joint == .thumbTip {
                // Right index finger on left thumb
                GameController.instance.changeDirection(by: 10.0)
            }
        }

        RBHandTracking.instance.setup()
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
        
        GameController.instance.setAirplanePosition(position)
        
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

        //let bounds =  airplane.model.mesh.bounds.extents
        //ring.components.set(CollisionComponent(shapes: [ring.generateCollisionShapes(recursive: true)]))
        ring.components.set(HoverEffectComponent())
        ring.components.set(InputTargetComponent())

        return ring
    }

}
