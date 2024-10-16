//
//  GameOverScene.swift
//  pb-runner
//
//  Created by ewan decima on 10/09/2024.
//

import SpriteKit
import SwiftUI

class GameOverScene: SKScene {
    @AppStorage("highScore") private var highScore: Int = 0
    @AppStorage("currentScore") private var currentScore: Int = 0
    
    override func didMove(to view: SKView) {
        
        AudioManager.shared.playBackgroundMusic(track: "gameOverSong")
        
        
        // Ajout d'un arrière-plan personnalisé
        let background = SKSpriteNode(imageNamed: "blurSky")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        
        background.zPosition = -1 // Assurez-vous que l'arrière-plan est derrière les autres éléments
        addChild(background)
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 110)
        gameOverLabel.fontName = "Invasion2000"
        gameOverLabel.fontColor = .black
        addChild(gameOverLabel)
        
        
        let currentScoreLabel = SKLabelNode(text: "You get \(currentScore) !")
        currentScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 80)
        currentScoreLabel.fontName = "Invasion2000"
        currentScoreLabel.fontColor = .black
        addChild(currentScoreLabel)
        
        
        
        let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
        highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        highScoreLabel.fontName = "Invasion2000"
        highScoreLabel.fontColor = .black
        addChild(highScoreLabel)
        
        let playAgainButton = SKLabelNode(text: "Play Again")
        playAgainButton.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        playAgainButton.name = "playAgainButton"
        playAgainButton.fontName = "Invasion2000"
        playAgainButton.fontSize = 50
        playAgainButton.fontColor = .black
        addChild(playAgainButton)
        
        // Ajouter une animation de pulsation au bouton "Play Again"
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        playAgainButton.run(repeatPulse)
        
        let quitButton = SKLabelNode(text: "Quit")
        quitButton.position = CGPoint(x: frame.midX - 100, y: frame.midY - 100)
        quitButton.name = "quitButton"
        quitButton.fontName = "Invasion2000"
        quitButton.fontColor = .black
        addChild(quitButton)
        
        
        let optionButton = SKLabelNode(text: "Option")
        optionButton.position = CGPoint(x: frame.midX + 100, y: frame.midY - 100)
        optionButton.name = "optionButton"
        optionButton.fontName = "Invasion2000"
        optionButton.fontColor = .black
        addChild(optionButton)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "playAgainButton" {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: .doorway(withDuration: 0.5))
        } else if touchedNode.name == "quitButton" {
            let mainMenuScene = MainMenuScene(size: size)
            mainMenuScene.scaleMode = .aspectFill
            view?.presentScene(mainMenuScene, transition: .doorway(withDuration: 0.5))
        } else if touchedNode.name == "optionButton" {
            let optionScene = OptionsScene(size: size)
            optionScene.scaleMode = .aspectFill
            view?.presentScene(optionScene, transition: .doorway(withDuration: 0.5))
        }
    }
}
