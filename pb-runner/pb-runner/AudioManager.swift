//
//  AudioManager.swift
//  pb-runner
//
//  Created by ewan decima on 25/09/2024.
//


import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var currentTrack: String?
    
    @Published var musicVolume: Double = UserDefaults.standard.double(forKey: "musicVolume") {
        didSet {
            backgroundMusicPlayer?.volume = Float(musicVolume)
            UserDefaults.standard.set(musicVolume, forKey: "musicVolume")
        }
    }
    
    private init() {
        // Initialize with the stored value or default to 0.5 if not set
        musicVolume = UserDefaults.standard.double(forKey: "musicVolume")
        if musicVolume == 0.0 {
            musicVolume = 0.5
            UserDefaults.standard.set(musicVolume, forKey: "musicVolume")
        }
    }
    
    func playBackgroundMusic(track: String) {
        guard track != currentTrack else { return }
        
        stopBackgroundMusic()
        
        guard let url = Bundle.main.url(forResource: track, withExtension: "mp3") else {
            print("Audio file not found: \(track)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = Float(musicVolume)
            backgroundMusicPlayer?.play()
            currentTrack = track
        } catch {
            print("Couldn't play audio: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        currentTrack = nil
    }
    
    func setMusicVolume(_ volume: Double) {
        musicVolume = volume
    }
}
