//
//  ControlSelector.swift
//  pb-runner
//
//  Created by ewan decima on 22/09/2024.
//


import SwiftUI



struct ControlSelector: View {
    
    @AppStorage("upOnTheRight") private var upOnTheRight: Bool = true
    
    
    
    
    var body: some View {
        HStack{
            if upOnTheRight {
                Image("arrowUp")
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 16 * 8, height: 16 * 8)
                    
                Text("Change order")
                    .font(.custom("Invasion2000", size: 10))
                    .onTapGesture {
                        upOnTheRight.toggle()
                    }
                    
                Image("arrowDown")
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 16 * 8, height: 16 * 8)
                
            } else {
                Image("arrowDown")
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 16 * 8, height: 16 * 8)
                
                
                Text("Change order")
                    .font(.custom("Invasion2000", size: 10))
                    .onTapGesture {
                        upOnTheRight.toggle()
                    }
                
                
                Image("arrowUp")
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 16 * 8, height: 16 * 8)
            }
            
            
            
            
        }
    }
}
