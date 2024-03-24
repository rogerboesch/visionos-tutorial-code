//
//  MainWindow.swift
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

struct MainWindow: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @EnvironmentObject var settings: GameSettings

    var body: some View {
        VStack {
            Text("VISION OS")
                .font(.system(size: 38))
            Text("FROM ZERO TO HERO")
                .font(.system(size: 28))

            switch self.settings.state {
            case .start:
                Button(action: {
                    self.settings.state = .placeAircraft

                    Task {
                        await openImmersiveSpace(id: "game_space")
                    }
                }) {
                    Text("Start Placing")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(.bordered)
            case .placeAircraft:
                Button(action: {
                    self.settings.state = .start
                }) {
                    Text("Cancel Placing")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(.bordered)
            case .placeRings:
                Button(action: {
                    self.settings.state = .placed
                }) {
                    Text("Stop Placing")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(.bordered)
            case .placed:
                Button(action: {
                    self.settings.state = .play
                }) {
                    Text("Start Playing")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(.bordered)
            case .play:
                Button(action: {
                    self.settings.state = .placed
                }) {
                    Text("Stop Playing")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(.bordered)
            case .end:
                Button(action: {
                    self.settings.state = .placed
                }) {
                    Text("Restart Game")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .padding()
                        .cornerRadius(8)
                }
                .padding()
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
