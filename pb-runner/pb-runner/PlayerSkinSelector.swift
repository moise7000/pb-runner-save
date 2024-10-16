//
//  PlayerSkinSelector.swift
//  pb-runner
//
//  Created by ewan decima on 17/09/2024.
//

import SwiftUI



struct PlayerSkinSelector: View {
    @Binding var selectedSkin: String
    
    let skins = [
        PlayerSkin(name: "Lombric", imageName: "jump"),
        PlayerSkin(name: "The Crown", imageName: "jumpCrown"),
        PlayerSkin(name: "Ghost Face", imageName: "jumpGhost"),
        PlayerSkin(name: "Purple Gum", imageName: "jumpPurple"),
        PlayerSkin(name: "Blue Slime", imageName: "jumpSlimeLombric"),
        PlayerSkin(name: "Snow Man", imageName: "jumpSnowman"),
        PlayerSkin(name: "Pizza", imageName: "jumpPizza"),
        PlayerSkin(name: "GoofyBot", imageName: "jumpRobot"),
        PlayerSkin(name: "Waly", imageName: "jumpEve"),
        PlayerSkin(name: "Sticky", imageName: "jumpStickman"),
        PlayerSkin(name: "Fanta Claus", imageName: "jumpSanta"),
        PlayerSkin(name: "Donatello", imageName: "jumpDonatello"),
        PlayerSkin(name: "Lombric Kid", imageName: "jumpKarateKid"),
        PlayerSkin(name: "Big Blue", imageName: "jumpBlue"),
        PlayerSkin(name: "Red Dragon", imageName: "jumpRedDragon"),
        PlayerSkin(name: "Orange Juice", imageName: "jumpOrange"),
        PlayerSkin(name: "Green Master", imageName: "jumpGreen"),
    ]
    
    var body: some View {
        VStack {
            Text("Select Player")
                .font(.custom("Invasion2000", size: 40))
                .font(.largeTitle)
                .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(skins) { skin in
                        VStack {
                            Image(skin.imageName)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedSkin == skin.imageName ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedSkin = skin.imageName
                                }
                            
                            Text(skin.name)
                                .font(.custom("Invasion2000", size: 15))
                                .font(.caption)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

