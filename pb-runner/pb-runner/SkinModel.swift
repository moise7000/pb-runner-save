//
//  SkinModel.swift
//  pb-runner
//
//  Created by ewan decima on 22/09/2024.
//

import Foundation


struct PlayerSkin: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}


struct BackgroundSkin : Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    var needZoom: Bool 
}
