//
//  App.swift
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

import RealityKit
import SwiftUI

struct EntityMovementViewModifier: ViewModifier {
    private let entity: Entity
    @State private var startTransform: Transform?

    init(moving entity: Entity) {
        self.entity = entity
    }

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .simultaneously(with: RotateGesture3D(constrainedToAxis: .y))
                    .targetedToEntity(entity)
                    .onChanged { value in
                        if startTransform == nil {
                            startTransform = entity.transform
                        }
                        
                        if let rotation = value.second?.rotation {
                            let rotationTransform = Transform(AffineTransform3D(rotation: rotation))
                            entity.transform.rotation = startTransform!.rotation * rotationTransform.rotation
                        }
                        else if let translation = value.first?.translation3D {
                            var convertedTranslation = value.convert(translation, from: .local, to: entity.parent!)
                            
                            convertedTranslation.y = 0
                            entity.transform.translation = startTransform!.translation + convertedTranslation
                        }
                    }
                    .onEnded { _ in
                        startTransform = nil
                    }
            )
    }
}

extension View {
    func enableMovingEntity(_ entity: Entity) -> some View {
        modifier(EntityMovementViewModifier(moving: entity))
    }
}
