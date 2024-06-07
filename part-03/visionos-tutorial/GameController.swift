//
//  GameController.swift
//  visionos-tutorial
//
//  Created by Roger Boesch on 06.06.2024.
//
//
//  GameSoundController.swift
//  skychaos
//
//  Created by Roger Boesch on 13.03.2024.
//

import Foundation
import RealityKit

typealias GameStateCallBack = (GameState, GameState) -> ()

class GameController {
    private static var INSTANCE: GameController? = nil

    private var gameState = GameState.start

    var onStateChanged: GameStateCallBack?
    var airplane: RBGameObject? = nil

    static var instance: GameController {
        get {
            if GameController.INSTANCE == nil {
                GameController.INSTANCE = GameController()
            }
            
            return GameController.INSTANCE!
        }
    }
    
    func changeState(to newValue: GameState) {
        let oldState = gameState
        gameState = newValue
        
        if newValue == .play {
            start()
        }
        
        rbDebug("Change game state from '\(oldState)' to '\(newValue)'")

        onStateChanged?(oldState, gameState)
    }
    
    private func update(deltaTime: Float) -> Bool {
        if gameState != .play {
            rbDebug("Stop game. Game state is '\(gameState)'")

            return false
        }
        
        airplane?.update(deltaTime: deltaTime)
        return true
    }

    private func start() {
        guard let airplane = self.airplane else { return }

        rbDebug("Start game")

        airplane.fly()
        
        let interval: TimeInterval = 1.0 / 60 // 60 FPS, call every 16.666 ms
        Timer.scheduledTimer(withTimeInterval:interval, repeats: true) { timer in
            if !self.update(deltaTime: Float(interval)) {
                timer.invalidate()
                return
            }
        }
    }
    
    func setAirplanePosition(_ pos: SIMD3<Float>) {
        guard let airplane = self.airplane else { return }

        rbDebug("Set airplane position: \(pos)")

        airplane.position = pos
    }
    
    func turnLeft() {
        guard let airplane = self.airplane else { return }

        rbDebug("Turn airplane left")

        let angle = airplane.angle - 90.0
        airplane.changeDirectionTo(angle: angle)
    }
    
    func turnRight() {
        guard let airplane = self.airplane else { return }

        rbDebug("Turn airplane right")

        let angle = airplane.angle + 90.0
        airplane.changeDirectionTo(angle: angle)
    }
}
