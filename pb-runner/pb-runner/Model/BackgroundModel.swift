//
//  SceneModel.swift
//  pb-runner
//
//  Created by ewan decima on 12/10/2024.
//

import Foundation
import SpriteKit
import GameplayKit

struct BackgroundLayer {
    let texture: SKTexture
    let speed: CGFloat
    let zPosition: CGFloat
}

struct BackgroundConfig {
    let layers: [BackgroundLayer]
    let groundTexture: SKTexture
    let hasSnowfall: Bool
    let music: String?
    
    // Add more properties as needed, e.g., obstacle types, player physics, etc.
}


let SNOW = BackgroundConfig(layers: [ BackgroundLayer(texture: <#T##SKTexture#>, speed: <#T##CGFloat#>, zPosition: <#T##CGFloat#>)], groundTexture: SKTexture(imageNamed: "snowGround"), hasSnowfall: true, music: "")
