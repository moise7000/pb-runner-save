//
//  MainMenuScene.swift
//  pb-runner
//
//  Created by ewan decima on 10/09/2024.
//


import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Ajout d'un arrière-plan personnalisé
        let background = SKSpriteNode(imageNamed: "mainMenu")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.texture?.filteringMode = .nearest
        background.size = self.size
        background.zPosition = -1 // Assurez-vous que l'arrière-plan est derrière les autres éléments
        addChild(background)
        
        let playButton = SKLabelNode(text: "Play")
        playButton.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        playButton.name = "playButton"
        playButton.fontName = "Invasion2000"
        playButton.fontSize = 50
//        playButton.fontColor = .black
        addChild(playButton)
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        playButton.run(repeatPulse)
        
        let optionsButton = SKLabelNode(text: "Options")
        optionsButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        optionsButton.name = "optionsButton"
        optionsButton.fontName = "Invasion2000"
//        optionsButton.fontColor = .black
        addChild(optionsButton)
        
        
        
        
        //MARK: Songs
        AudioManager.shared.playBackgroundMusic(track: "mainMenuSong")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "playButton" {
            
            
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFit
            view?.presentScene(gameScene, transition: .doorway(withDuration: 0.5))
        } else if touchedNode.name == "optionsButton" {
            let optionsScene = OptionsScene(size: size)
            optionsScene.scaleMode = .aspectFill
            view?.presentScene(optionsScene, transition: .doorway(withDuration: 0.5))
        }
    }
}
