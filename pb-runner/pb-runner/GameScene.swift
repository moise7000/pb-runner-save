//
//  GameScene.swift
//  pb-runner
//
//  Created by ewan decima on 10/09/2024.
//

import SpriteKit
import GameplayKit

import SwiftUI


enum ObstacleType: CaseIterable {
    case single
    case double
    case large
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    @AppStorage("upOnTheRight") private var upOnTheRight: Bool = true
    
    @AppStorage("highScore") private var highScore: Int = 0
    @AppStorage("currentScore") private var currentScore: Int = 0
    
    @AppStorage("selectedSkin") private var selectedSkin: String = "jumpCrown"
    @AppStorage("selectedBackgroundSkin") private var selectedBackgroundSkin = "blurSky"
    @AppStorage("backgroundNeedZoom") private var backgroundNeedZoom = false
    
    private var player: SKSpriteNode!
    private var ground: SKSpriteNode!
    private var background: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    
    private var upButton: SKSpriteNode!
    private var downButton: SKSpriteNode!
    
    private var runningTexture: SKTexture!
    private var jumpingTexture: SKTexture!
    private var runningFrames: [SKTexture] = []
    private var jumpingFrames: [SKTexture] = []
    
    private var obstacles: [SKSpriteNode] = [] // Pour garder une référence à tous les obstacles actifs
    
    private var snowflakes: [SKSpriteNode] = []
    private var snowAngle: CGFloat = 7 * CGFloat.pi / 4
    private var snowSpeed: CGFloat = 5 // Vitesse de chute par défaut
    private var snowRotationSpeed: CGFloat = 1 // Vitesse de rotation par défaut (en radians par seconde)
    private var snowWaveAmplitude: CGFloat = 10 // Amplitude de l'ondulation horizontale
    private var snowWaveFrequency: CGFloat = 1 // Fréquence de l'ondulation
    
    private var isJumping = false
    private var isOnGround = true
    private var canJump = true
    private var isAirborne = false

    
    private var score = 0 // Variable pour le score
    
    
    // Constantes pour la taille des frames et le nombre de frames
    private let frameSize = CGSize(width: 16, height: 16)
    private let runningFrameCount = 8 // Nombre de frames de course dans le spritesheet
    private let jumpingFrameCount = 1 // Nombre de frames de saut dans le spritesheet
    
    // Facteur de zoom pour le personnage
    private let zoomFactor: CGFloat = 4
    private let zoomFactorForMob: CGFloat = 1.5
    
    // Catégories de collision
    private let playerCategory: UInt32 = 0x1 << 0
    private let groundCategory: UInt32 = 0x1 << 1
    private let obstacleCategory: UInt32 = 0x1 << 2
    
    // Rayon de la hitbox des obstacles
    private let obstacleHitboxRadius: CGFloat = 1.5
    
    
    
    
    private var lastObstaclePosition: CGFloat = 0
    private let minObstacleDistance: CGFloat = 200 // Distance minimale entre les obstacles
    
    
    
    private var backgroundLayers: [SKSpriteNode] = []
    private let numberOfLayers = 5
    private let parallaxFactor: CGFloat = 0.5
    
    
    
    
    private var lastUpdateTime: TimeInterval = 0
    private var timeSinceLastObstacle: TimeInterval = 0
    private var baseObstacleInterval: TimeInterval = 2.0
    private var obstacleIntervalVariance: TimeInterval = 0.5
    private var difficultyFactor: CGFloat = 0.2  // Increased difficulty factor
    
    override func didMove(to view: SKView) {
        if selectedBackgroundSkin == "ice" {
            startSnowfall()
        }
        
        currentScore = 0
        setupBackground()
        setupGround()
        setupPhysics()
        setupPlayer()
        createAnimations()
        setupScoreLabel()
        setupJumpButtons()
        
        self.physicsWorld.contactDelegate = self
        
        // Ajouter un recognizer pour le swipe vers le bas
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        print("Swipe down recognizer added")
    }
    
    private func setupJumpButtons() {
            // Up button
        let buttonUpTexture = SKTexture(imageNamed: "arrowUp")
        buttonUpTexture.filteringMode = .nearest
        upButton = SKSpriteNode(texture: buttonUpTexture)
        upButton.size = CGSize(width: 16 * 8, height: 16 * 8)
        if upOnTheRight{
            upButton.position = CGPoint(x: 100, y: frame.minY + 200)
        } else {
            upButton.position = CGPoint(x: frame.maxX - 60, y: frame.minY + 200)
            
        }
        
        upButton.zPosition = 10
        upButton.alpha = 0.3
        upButton.name = "upButton"
        addChild(upButton)

            // Down button
        let buttonDownTexture = SKTexture(imageNamed: "arrowDown")
        buttonDownTexture.filteringMode = .nearest
        downButton = SKSpriteNode(texture: buttonDownTexture)
        downButton.size = CGSize(width: 16 * 8, height: 16 * 8)
        
        if upOnTheRight{
            downButton.position = CGPoint(x: frame.maxX - 60, y: frame.minY + 200)
        } else {
            downButton.position = CGPoint(x: 100, y: frame.minY + 200)
            
        }
        
        
        downButton.alpha = 0.3
        downButton.zPosition = 10
        downButton.name = "downButton"
        addChild(downButton)
        }
    
    private func jumpUp() {
            guard !isJumping else { return }
            
        
        print("jump up")
            isJumping = true
            player.removeAction(forKey: "runningAnimation")
            player.texture = jumpingTexture
            
            let jumpAction = SKAction.applyImpulse(CGVector(dx: 0, dy: 200), duration: 0.1)
            player.run(jumpAction)
        }

    private func jumpDown() {
        //guard !isJumping else { return }
        
        print("jump down")
        isJumping = true
        player.removeAction(forKey: "runningAnimation")
        player.texture = jumpingTexture
        
        let jumpDownAction = SKAction.applyImpulse(CGVector(dx: 0, dy: -700), duration: 0.1)
        player.run(jumpDownAction)
    }
    
    
    private func setupBackground() {
            for i in 0..<numberOfLayers {
                let layerName = "\(selectedBackgroundSkin)_layer\(i+1)"
                let backgroundTexture = SKTexture(imageNamed: layerName)
                backgroundTexture.filteringMode = .nearest
                
                let backgroundLayer = SKSpriteNode(texture: backgroundTexture)
                if backgroundNeedZoom {
                    backgroundLayer.size = CGSize(width: 256 * zoomFactorForMob * 10, height: 128 * zoomFactorForMob * 10)
                } else {
                    backgroundLayer.size = CGSize(width: self.frame.width, height: self.frame.height)
                }
                
                backgroundLayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                backgroundLayer.zPosition = -CGFloat(numberOfLayers - i)
                
                // Créer une copie de la couche pour un défilement continu
                let backgroundLayerCopy = backgroundLayer.copy() as! SKSpriteNode
                backgroundLayerCopy.position = CGPoint(x: backgroundLayer.position.x + backgroundLayer.size.width, y: backgroundLayer.position.y)
                
                addChild(backgroundLayer)
                addChild(backgroundLayerCopy)
                
                backgroundLayers.append(backgroundLayer)
                backgroundLayers.append(backgroundLayerCopy)
            }
        }
    
    private func updateBackgroundParallax() {
            let baseSpeed = groundSpeed()
            
            for (index, layer) in backgroundLayers.enumerated() {
                // Calcul de la vitesse corrigée
                let layerIndex = CGFloat(index / 2) // Car chaque couche a une copie
                let layerSpeed = baseSpeed * pow(parallaxFactor, CGFloat(numberOfLayers - 1) - layerIndex)
                
                layer.position.x -= layerSpeed
                
                // Si la couche est complètement hors de l'écran, la replacer
                if layer.position.x <= -layer.size.width / 2 {
                    layer.position.x += layer.size.width * 2
                }
            }
        }
    
    
    
    
    
    
    
    
    
    
    

    private func setupGround() {
        
        let groundName = selectedBackgroundSkin + "Ground"
            let groundHeight: CGFloat = 50
            let groundTexture = SKTexture(imageNamed: groundName)
            groundTexture.filteringMode = .nearest
            
            // Créer trois instances de sol pour l'effet de défilement sans espaces
            for i in 0...2 {
                ground = SKSpriteNode(texture: groundTexture)
                ground.size = CGSize(width: self.frame.width + 2, height: groundHeight) // Ajout d'un pixel supplémentaire
                ground.position = CGPoint(x: CGFloat(i) * self.frame.width, y: groundHeight / 2)
                ground.zPosition = 1 // Assurez-vous que le sol est au-dessus du fond
                
                ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
                ground.physicsBody?.isDynamic = false
                ground.physicsBody?.categoryBitMask = groundCategory
                ground.physicsBody?.contactTestBitMask = playerCategory
                ground.physicsBody?.collisionBitMask = playerCategory
                
                addChild(ground)
                
                let moveLeft = SKAction.moveBy(x: -self.frame.width, y: 0, duration: TimeInterval(groundSpeed()))
                let resetPosition = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0)
                let moveSequence = SKAction.sequence([moveLeft, resetPosition])
                let moveForever = SKAction.repeatForever(moveSequence)
                
                ground.run(moveForever)
            }
        }
    
    private func setupPhysics() {
            physicsWorld.gravity = CGVector(dx: 0, dy: -19.8) // Gravité normale
            physicsWorld.contactDelegate = self
        }



    
    //MARK: With skin implementation
    private func setupPlayer() {
            // Utiliser le skin sélectionné
            let skinName = selectedSkin.replacingOccurrences(of: "jump", with: "run")
            runningTexture = SKTexture(imageNamed: skinName)
            jumpingTexture = SKTexture(imageNamed: selectedSkin)
            runningTexture.filteringMode = .nearest
            jumpingTexture.filteringMode = .nearest
                    
            player = SKSpriteNode(texture: runningTexture)
            player.size = CGSize(width: 16 * zoomFactor, height: 16 * zoomFactor)
                
            let playerY = ground.frame.maxY + player.size.height / 2
            player.position = CGPoint(x: frame.midX / 2, y: playerY)
                
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.isDynamic = true
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.restitution = 0.0
            player.physicsBody?.friction = 1.0
            player.physicsBody?.linearDamping = 0.5
            player.physicsBody?.categoryBitMask = playerCategory
            player.physicsBody?.contactTestBitMask = groundCategory | obstacleCategory
            player.physicsBody?.collisionBitMask = groundCategory | obstacleCategory
                
            addChild(player)
        }

    
    
    private func createAnimations() {
            let skinName = selectedSkin.replacingOccurrences(of: "jump", with: "run")
            let runSpritesheet = SKTexture(imageNamed: skinName)
            runSpritesheet.filteringMode = .nearest
                
            // Création de l'animation de course
            let frameWidth = 16.0 / 128.0 // Largeur d'une frame par rapport à la largeur totale de l'image
            for i in 0..<8 { // 8 frames de course
                let rect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: 1.0)
                let texture = SKTexture(rect: rect, in: runSpritesheet)
                runningFrames.append(texture)
            }
                
            // Lancer l'animation de course par défaut
            let runAnimation = SKAction.animate(with: runningFrames, timePerFrame: 0.1)
            player.run(SKAction.repeatForever(runAnimation), withKey: "runningAnimation")
        }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Invasion2000")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.red
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
    }
    
    private func updateScore() {
        score += 1
        currentScore += 1
        scoreLabel.text = "Score: \(score)"
        if score > highScore {
            highScore = score
        }
    }
    
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)

            if upButton.contains(location) {
                jumpUp()
            }
        if downButton.contains(location) {
                jumpDown()
            }
        }

    @objc private func handleSwipeDown(_ sender: UISwipeGestureRecognizer) {
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -700))
    }
    
    
    

    func didBegin(_ contact: SKPhysicsContact) {
            let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if collision == (playerCategory | groundCategory) {
                if isJumping {
                    isJumping = false
                    
                    player.physicsBody?.velocity.dy = 0
                    
                    let runAnimation = SKAction.animate(with: runningFrames, timePerFrame: 0.1)
                    player.run(SKAction.repeatForever(runAnimation), withKey: "runningAnimation")
                }
            } else if collision == (playerCategory | obstacleCategory) {
                gameOver()
            }
        }



    
    private func gameOver() {
        // Arrêter toutes les actions et la physique
        self.isPaused = true
        
        // Attendre un court instant avant de passer à l'écran de game over
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.scaleMode = .aspectFill
            self.view?.presentScene(gameOverScene, transition: .crossFade(withDuration: 0.5))
        }
    }
    
    private func groundSpeed() -> CGFloat {
        let speed =  3.0 - CGFloat(score) * 0.1 // Augmente la vitesse en fonction du score
        return max(speed, 1.5)
    }
    
    
    
    //MARK: New obstacle logic
    
    


    private func obstacleSpeed() -> CGFloat {
        let baseSpeed: CGFloat = 500 // Vitesse de base en points par seconde
        let speedIncrease: CGFloat = CGFloat(score) * difficultyFactor
        return min(baseSpeed + speedIncrease, 400) // Vitesse maximale de 400 points par seconde
    }

    private func calculateNextObstacleTime() -> TimeInterval {
        let intervalReduction = min(Double(score) * Double(difficultyFactor), 1.5)  // Increased max reduction
        let adjustedBaseInterval = max(baseObstacleInterval - intervalReduction, 0.5)  // Ensure minimum interval
        return adjustedBaseInterval + Double.random(in: -obstacleIntervalVariance...obstacleIntervalVariance)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
    
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        timeSinceLastObstacle += deltaTime
        
        if timeSinceLastObstacle > calculateNextObstacleTime() {
            spawnObstacle()
            timeSinceLastObstacle = 0
        }
        
        if !isOnGround && player.texture != jumpingTexture {
            player.texture = jumpingTexture
        }
        
        updateBackgroundParallax()
        
        // Déplacer tous les obstacles
        for obstacle in obstacles {
            obstacle.position.x -= CGFloat(obstacleSpeed()) * CGFloat(deltaTime)
        }
        
        
        
        // Vérifier et supprimer les obstacles qui sont sortis de l'écran
        obstacles = obstacles.filter { obstacle in
            if obstacle.position.x + obstacle.size.width / 2 < 0 {
                obstacle.removeFromParent()
                updateScore()
                return false
            }
            return true
        }
        
        if selectedBackgroundSkin == "ice" {
                    updateSnowflakes(currentTime)
                } else {
                    // Arrêtez la chute de neige si le fond n'est pas "ice"
                    removeAction(forKey: "snowfall")
                    for snowflake in snowflakes {
                        snowflake.removeFromParent()
                    }
                    snowflakes.removeAll()
                }
        
        
    }

    private func spawnObstacle() {
        let obstacleType = ObstacleType.allCases.randomElement()!
            
        switch obstacleType {
        case .single:
            spawnSingleObstacle()
        case .double:
            spawnDoubleObstacle()
        case .large:
            spawnLargeObstacle()
        }
    }
    
    
    private func spawnSingleObstacle() {
            let obstacle = createObstacle(size: CGSize(width: 58 * zoomFactorForMob, height: 42 * zoomFactorForMob))
            positionAndMoveObstacle(obstacle)
        }

        private func spawnDoubleObstacle() {
            let obstacle1 = createObstacle(size: CGSize(width: 58 * zoomFactorForMob / 2, height: 42 * zoomFactorForMob / 2), image: "blueBoatMob")
            let obstacle2 = createObstacle(size: CGSize(width: 58 * zoomFactorForMob / 2, height: 42 * zoomFactorForMob / 2), image: "blueBoatMob")
            
            obstacle2.position.x = obstacle1.position.x + obstacle1.size.width
            
            positionAndMoveObstacle(obstacle1)
            positionAndMoveObstacle(obstacle2)
        }

        private func spawnLargeObstacle() {
            let obstacle = createObstacle(size: CGSize(width: 87 * zoomFactorForMob, height: 63 * zoomFactorForMob), image: "yellowBoatMob")
            positionAndMoveObstacle(obstacle)
        }
    
    private func createObstacle(size: CGSize, image: String = "boatMob") -> SKSpriteNode {
            let obstacleTexture = SKTexture(imageNamed: image)
            obstacleTexture.filteringMode = .nearest
            
            let obstacle = SKSpriteNode(texture: obstacleTexture)
            obstacle.size = size
            
            obstacle.physicsBody = SKPhysicsBody(circleOfRadius: obstacleHitboxRadius)
            obstacle.physicsBody?.isDynamic = false
            obstacle.physicsBody?.categoryBitMask = obstacleCategory
            obstacle.physicsBody?.contactTestBitMask = playerCategory
            obstacle.physicsBody?.collisionBitMask = playerCategory
            
            return obstacle
        }
    
    private func positionAndMoveObstacle(_ obstacle: SKSpriteNode) {
            let startX = frame.maxX + obstacle.size.width / 2
            
            if startX - lastObstaclePosition < minObstacleDistance {
                obstacle.position.x = lastObstaclePosition + minObstacleDistance
            } else {
                obstacle.position.x = startX
            }
            
            obstacle.position.y = ground.position.y + ground.size.height / 2 + obstacle.size.height / 2
            addChild(obstacle)
            obstacles.append(obstacle)
            
            lastObstaclePosition = obstacle.position.x
        }
    
    
    
    
    
    //MARK: Snowflakes
    private func startSnowfall() {
            let createSnowflake = SKAction.run { [weak self] in
                guard let self = self else { return }
                let snowflake = self.createSnowflake()
                self.addChild(snowflake)
                self.snowflakes.append(snowflake)
            }
            
            let wait = SKAction.wait(forDuration: 0.1) // Ajustez cette durée pour changer la fréquence des flocons
            let sequence = SKAction.sequence([createSnowflake, wait])
            run(SKAction.repeatForever(sequence), withKey: "snowfall")
        }
    

    
    private func createSnowflake() -> SKSpriteNode {
        let snowflakeTexture = SKTexture(imageNamed: "snowflake")
        snowflakeTexture.filteringMode = .nearest
        let snowflake = SKSpriteNode(texture: snowflakeTexture)
        snowflake.size = CGSize(width: 15 * 1.5, height: 16 * 1.5) // Ajustez la taille selon vos besoins
        snowflake.position = CGPoint(x: CGFloat.random(in: 0...frame.width), y: frame.height + snowflake.size.height)
        snowflake.zPosition = 5 // Assurez-vous que les flocons sont au-dessus du fond mais en dessous des autres éléments
            
            // Ajout de l'effet lumineux
        snowflake.addGlow()
            
            // Ajout de la rotation
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: TimeInterval(1 / snowRotationSpeed))
        snowflake.run(SKAction.repeatForever(rotateAction))
            
            // Stockage de la position initiale pour le calcul de la trajectoire
        snowflake.userData = ["initialX": snowflake.position.x]
            
        return snowflake
        }
    

    
    private func updateSnowflakes(_ currentTime: TimeInterval) {
        for snowflake in snowflakes {
            guard let initialX = snowflake.userData?["initialX"] as? CGFloat else { continue }
                
                // Calcul de la nouvelle position avec une trajectoire sinusoïdale
            let elapsedDistance = frame.height + snowflake.size.height - snowflake.position.y
            let waveFactor = sin(elapsedDistance / frame.height * snowWaveFrequency * .pi * 2)
            let horizontalOffset = waveFactor * snowWaveAmplitude
                
            let movement = CGVector(
                dx: sin(snowAngle) * snowSpeed + horizontalOffset,
                dy: -cos(snowAngle) * snowSpeed
            )
            snowflake.position = CGPoint(
                x: initialX + horizontalOffset,
                y: snowflake.position.y + movement.dy
            )
                
                // Supprimez les flocons qui sont sortis de l'écran
            if snowflake.position.y < -snowflake.size.height {
                snowflake.removeFromParent()
                if let index = snowflakes.firstIndex(of: snowflake) {
                    snowflakes.remove(at: index)
                }
            }
        }
    }
}




extension SKSpriteNode {
    func addGlow(radius: CGFloat = 10, color: UIColor = .white) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
        
        let glowNode = SKSpriteNode(color: color, size: size)
        glowNode.alpha = 0.5
        effectNode.addChild(glowNode)
    }
}



extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGVector) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }
}


