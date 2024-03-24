//
//  GameWindow.swift

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

struct GameWindow: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @EnvironmentObject var settings: GameSettings

    var body: some View {
        VStack {
            Text("GAME")
                .font(.system(size: 38))

            Button(action: {
                dismissWindow(id: "game_window")
                openWindow(id: "main_window")
                
                Task {
                    await dismissImmersiveSpace()
                }
            }) {
                Text("STOP")
            }
            .padding()
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear() {
            dismissWindow(id: "main_window")
        }
    }
}
