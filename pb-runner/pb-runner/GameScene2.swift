//
//  BackgroundLayer.swift
//  pb-runner
//
//  Created by ewan decima on 12/10/2024.
//


import SpriteKit
import GameplayKit
import SwiftUI


class GameScene2: SKScene, SKPhysicsContactDelegate {
    @AppStorage("upOnTheRight") private var upOnTheRight: Bool = true
    @AppStorage("highScore") private var highScore: Int = 0
    @AppStorage("currentScore") private var currentScore: Int = 0
    @AppStorage("selectedSkin") private var selectedSkin: String = "jumpCrown"
    
    private var player: SKSpriteNode!
    private var ground: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var upButton: SKSpriteNode!
    private var downButton: SKSpriteNode!
    
    private var runningTexture: SKTexture!
    private var jumpingTexture: SKTexture!
    private var runningFrames: [SKTexture] = []
    private var jumpingFrames: [SKTexture] = []
    
    private var obstacles: [SKSpriteNode] = []
    private var snowflakes: [SKSpriteNode] = []
    
    private var isJumping = false
    private var isOnGround = true
    private var canJump = true
    private var isAirborne = false
    
    private var score = 0
    private var lastUpdateTime: TimeInterval = 0
    private var timeSinceLastObstacle: TimeInterval = 0
    private var baseObstacleInterval: TimeInterval = 2.0
    private var obstacleIntervalVariance: TimeInterval = 0.5
    private var difficultyFactor: CGFloat = 0.2
    
    private let frameSize = CGSize(width: 16, height: 16)
    private let runningFrameCount = 8
    private let jumpingFrameCount = 1
    private let zoomFactor: CGFloat = 4
    private let zoomFactorForMob: CGFloat = 1.5
    private let obstacleHitboxRadius: CGFloat = 1.5
    
    private let playerCategory: UInt32 = 0x1 << 0
    private let groundCategory: UInt32 = 0x1 << 1
    private let obstacleCategory: UInt32 = 0x1 << 2
    
    private var backgroundLayers: [SKSpriteNode] = []
    private var currentBackgroundConfig: BackgroundConfig!
    
    // Snowfall properties
    private var snowAngle: CGFloat = 7 * CGFloat.pi / 4
    private var snowSpeed: CGFloat = 5
    private var snowRotationSpeed: CGFloat = 1
    private var snowWaveAmplitude: CGFloat = 10
    private var snowWaveFrequency: CGFloat = 1
    
    convenience init(size: CGSize, backgroundType: String) {
        self.init(size: size)
        self.currentBackgroundConfig = getBackgroundConfig(for: backgroundType)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        guard currentBackgroundConfig != nil else {
            fatalError("Background configuration not set. Use the custom initializer.")
        }
        
        setupScene()
    }
    
    private func setupScene() {
        setupBackground()
        setupGround()
        setupPhysics()
        setupPlayer()
        createAnimations()
        setupScoreLabel()
        setupJumpButtons()
        
        if currentBackgroundConfig.hasSnowfall {
            startSnowfall()
        }
        
        if let musicName = currentBackgroundConfig.music {
            //playBackgroundMusic(named: musicName)
        }
        
        self.physicsWorld.contactDelegate = self
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDown.direction = .down
        view?.addGestureRecognizer(swipeDown)
    }
    
    private func setupBackground() {
        for (index, layer) in currentBackgroundConfig.layers.enumerated() {
            let backgroundNode = createBackgroundNode(with: layer.texture)
            backgroundNode.zPosition = layer.zPosition
            addChild(backgroundNode)
            backgroundLayers.append(backgroundNode)
            
            let secondNode = createBackgroundNode(with: layer.texture)
            secondNode.position = CGPoint(x: backgroundNode.size.width, y: 0)
            secondNode.zPosition = layer.zPosition
            addChild(secondNode)
            backgroundLayers.append(secondNode)
            
            scrollBackground(backgroundNode, secondNode, speed: layer.speed)
        }
    }
    
    private func createBackgroundNode(with texture: SKTexture) -> SKSpriteNode {
        let backgroundNode = SKSpriteNode(texture: texture)
        backgroundNode.size = self.size
        backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        return backgroundNode
    }
    
    private func scrollBackground(_ first: SKSpriteNode, _ second: SKSpriteNode, speed: CGFloat) {
        let moveLeft = SKAction.moveBy(x: -first.size.width, y: 0, duration: TimeInterval(speed))
        let resetPosition = SKAction.moveBy(x: first.size.width, y: 0, duration: 0)
        let sequence = SKAction.sequence([moveLeft, resetPosition])
        let infiniteScroll = SKAction.repeatForever(sequence)
        
        first.run(infiniteScroll)
        second.run(infiniteScroll)
    }
    
    private func setupGround() {
        let groundTexture = currentBackgroundConfig.groundTexture
        groundTexture.filteringMode = .nearest
        
        let groundHeight: CGFloat = 50
        
        for i in 0...2 {
            ground = SKSpriteNode(texture: groundTexture)
            ground.size = CGSize(width: self.frame.width + 2, height: groundHeight)
            ground.position = CGPoint(x: CGFloat(i) * self.frame.width, y: groundHeight / 2)
            ground.zPosition = 1
            
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
        physicsWorld.gravity = CGVector(dx: 0, dy: -19.8)
        physicsWorld.contactDelegate = self
    }
    
    private func setupPlayer() {
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
        
        let frameWidth = 16.0 / 128.0
        for i in 0..<8 {
            let rect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: 1.0)
            let texture = SKTexture(rect: rect, in: runSpritesheet)
            runningFrames.append(texture)
        }
        
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
    
    private func setupJumpButtons() {
        let buttonUpTexture = SKTexture(imageNamed: "arrowUp")
        buttonUpTexture.filteringMode = .nearest
        upButton = SKSpriteNode(texture: buttonUpTexture)
        upButton.size = CGSize(width: 16 * 8, height: 16 * 8)
        upButton.position = CGPoint(x: upOnTheRight ? frame.maxX - 60 : 100, y: frame.minY + 200)
        upButton.zPosition = 10
        upButton.alpha = 0.3
        upButton.name = "upButton"
        addChild(upButton)
        
        let buttonDownTexture = SKTexture(imageNamed: "arrowDown")
        buttonDownTexture.filteringMode = .nearest
        downButton = SKSpriteNode(texture: buttonDownTexture)
        downButton.size = CGSize(width: 16 * 8, height: 16 * 8)
        downButton.position = CGPoint(x: upOnTheRight ? 100 : frame.maxX - 60, y: frame.minY + 200)
        downButton.alpha = 0.3
        downButton.zPosition = 10
        downButton.name = "downButton"
        addChild(downButton)
    }
    
    private func jumpUp() {
        guard !isJumping else { return }
        
        isJumping = true
        player.removeAction(forKey: "runningAnimation")
        player.texture = jumpingTexture
        
        let jumpAction = SKAction.applyImpulse(CGVector(dx: 0, dy: 200), duration: 0.1)
        player.run(jumpAction)
    }
    
    private func jumpDown() {
        isJumping = true
        player.removeAction(forKey: "runningAnimation")
        player.texture = jumpingTexture
        
        let jumpDownAction = SKAction.applyImpulse(CGVector(dx: 0, dy: -700), duration: 0.1)
        player.run(jumpDownAction)
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
        self.isPaused = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.scaleMode = .aspectFill
            self.view?.presentScene(gameOverScene, transition: .crossFade(withDuration: 0.5))
        }
    }
    
    private func groundSpeed() -> CGFloat {
        let speed = 3.0 - CGFloat(score) * 0.1
        return max(speed, 1.5)
    }
    
    private func obstacleSpeed() -> CGFloat {
        let baseSpeed: CGFloat = 500
        let speedIncrease: CGFloat = CGFloat(score) * difficultyFactor
        return min(baseSpeed + speedIncrease, 400)
    }
    
    private func calculateNextObstacleTime() -> TimeInterval {
        let intervalReduction = min(Double(score) * Double(difficultyFactor), 1.5)
        let adjustedBaseInterval = max(baseObstacleInterval - intervalReduction, 0.5)
        return adjustedBaseInterval + Double.random(in: -obstacleIntervalVariance...obstacleIntervalVariance)
    }
    
    
    private func getBackgroundConfig(for type: String) -> BackgroundConfig {
            switch type {
            case "snow":
                return BackgroundConfig(
                    layers: [
                        BackgroundLayer(texture: SKTexture(imageNamed: "snowParalax_5"), speed: 400, zPosition: -1),
                        BackgroundLayer(texture: SKTexture(imageNamed: "snowParalax_4"), speed: 200, zPosition: -2),
                        BackgroundLayer(texture: SKTexture(imageNamed: "snowParalax_3"), speed: 100, zPosition: -3),
                        BackgroundLayer(texture: SKTexture(imageNamed: "snowParalax_2"), speed: 50, zPosition: -4),
                        BackgroundLayer(texture: SKTexture(imageNamed: "snowParalax_1"), speed: 25, zPosition: -5)
                    ],
                    groundTexture: SKTexture(imageNamed: "snowGround"),
                    hasSnowfall: true,
                    music: "snowTheme.mp3"
                )
            case "cave":
                return BackgroundConfig(
                    layers: [
                        BackgroundLayer(texture: SKTexture(imageNamed: "caveBackground"), speed: 80, zPosition: -1)
                    ],
                    groundTexture: SKTexture(imageNamed: "caveGround"),
                    hasSnowfall: false,
                    music: "caveTheme.mp3"
                )
            // ... other background types ...
            default:
                fatalError("Unknown background type: \(type)")
            }
        }
    
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        timeSinceLastObstacle += deltaTime
        
        if timeSinceLastObstacle > calculateNextObstacleTime() {
            //spawnObstacle()
            timeSinceLastObstacle = 0
        }
        
        if !isOnGround && player.texture != jumpingTexture {
            player.texture = jumpingTexture
        }
        
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
        
        if currentBackgroundConfig.hasSnowfall {
            updateSnowflakes(currentTime)
        }
        
        
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

