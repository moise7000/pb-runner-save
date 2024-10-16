//
//  BackgroundSelector.swift
//  pb-runner
//
//  Created by ewan decima on 22/09/2024.
//


import SwiftUI



struct BackgroundSelector: View {
    @Binding var selectedBackgroundSkin: String
    @Binding var backgroundNeedZoom: Bool
    
    let skins = [
        BackgroundSkin(name: "Sky", imageName: "blurSky", needZoom: true),
        BackgroundSkin(name: "Snow", imageName: "snow", needZoom: false),
        BackgroundSkin(name: "Cave", imageName: "brownCave", needZoom: false),
        BackgroundSkin(name: "Blue Cave", imageName: "blueCave", needZoom: false),
        BackgroundSkin(name: "Ice Landscape", imageName: "ice", needZoom: false)
    ]
    
    var body: some View {
        VStack {
            Text("Select Background")
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
                                .frame(width: 256 * 0.75, height: 128 * 0.75)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedBackgroundSkin == skin.imageName ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedBackgroundSkin = skin.imageName
                                    backgroundNeedZoom = skin.needZoom
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

