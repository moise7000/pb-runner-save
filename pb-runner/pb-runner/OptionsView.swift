import SwiftUI

struct OptionsView: View {
    @AppStorage("selectedSkin") private var selectedSkin = "jump"
    @AppStorage("selectedBackgroundSkin") private var selectedBackgroundSkin = "blurSky"
    @AppStorage("backgroundNeedZoom") private var backgroundNeedZoom = false
    @AppStorage("highScore") private var highScore: Int = 0
    
    
    @State private var musicVolume: Double = AudioManager.shared.musicVolume
    
    @State private var soundVolume = 0.5
    
    var onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("mainMenu")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        
                        
                        //MARK: Player Customization
                        VStack(alignment: .leading) {
                            Text("Player Customization")
                                .font(.custom("Invasion2000", size: 20))
                                .foregroundColor(.white)
                            PlayerSkinSelector(selectedSkin: $selectedSkin)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        
                        
                        
                        
                        //MARK: Player Customization
                        VStack(alignment: .leading) {
                            Text("Background Customization")
                                .font(.custom("Invasion2000", size: 20))
                                .foregroundColor(.white)
                            BackgroundSelector(selectedBackgroundSkin: $selectedBackgroundSkin, backgroundNeedZoom: $backgroundNeedZoom)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        
                        
                        //MARK: Control Customisation
                        VStack(alignment: .leading) {
                            Text("Control Customization")
                                .font(.custom("Invasion2000", size: 20))
                                .foregroundColor(.white)
                            ControlSelector()
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)

                        
                        
                        
                        //MARK: Audio Settings
                        VStack(alignment: .leading) {
                            Text("Audio Settings")
                                .font(.custom("Invasion2000", size: 20))
                                .foregroundColor(.white)
                            
                            VStack {
                                Text("Sound Effects Volume")
                                    .font(.custom("Invasion2000", size: 16))
                                    .foregroundColor(.white)
                                Slider(value: $soundVolume, in: 0...1, step: 0.1)
                                    .accentColor(.white)
                            }
                            
                            VStack {
                                Text("Music Volume")
                                    .font(.custom("Invasion2000", size: 16))
                                    .foregroundColor(.white)
                                Slider(value: $musicVolume, in: 0...1, step: 0.1) { _ in
                                    AudioManager.shared.setMusicVolume(musicVolume)
                                }
                                    .accentColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        
                        // Score Settings
                        VStack(alignment: .leading) {
                            Text("Score Settings")
                                .font(.custom("Invasion2000", size: 20))
                                .foregroundColor(.white)
                            
                            Text("Current High Score: \(highScore)")
                                .font(.custom("Invasion2000", size: 16))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                highScore = 0
                            }) {
                                Text("Reset high score")
                                    .font(.custom("Invasion2000", size: 14))
                                    .foregroundColor(.red)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Options", displayMode: .inline)
            .navigationBarItems(leading: Button(action: onDismiss) {
                Text("Back to Main Menu")
                    .font(.custom("Invasion2000", size: 14))
                    .foregroundColor(.white)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
