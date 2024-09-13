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

import SwiftUI

@main
struct GameApp: App {
    @StateObject var settings = GameSettings()

    var body: some Scene {
        WindowGroup(id: "main_window") {
            MainWindow()
                .environmentObject(settings)
        }

        WindowGroup(id: "game_window") {
            GameWindow()
                .environmentObject(settings)
        }
        .defaultSize(width: 0.4, height: 0.3, depth: 0.0, in: .meters)

        ImmersiveSpace(id: "game_space") {
            GameSpace()
                .environmentObject(settings)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

