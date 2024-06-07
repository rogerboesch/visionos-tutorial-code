//
//  GameSettings.swift
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

import Foundation

enum GameState {
    case start              // Intro Dialog (2D)
    case placeAircraft      // Place aircraft (3D)
    case placeRings         // Place rings (3D)
    case placed             // All placed, ready to play (3D)
    case play               // Game
    case end                // Game ends (Can play again)
}

class GameSettings: ObservableObject {
    @Published var state: GameState = .start
}

