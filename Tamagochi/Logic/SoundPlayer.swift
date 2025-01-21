//
//  SoundPlayer.swift
//  Tamagochi
//
//  Created by Systems
//

import Foundation
import AVFoundation
import ActivityKit
import Combine

class SoundPlayer: NSObject {
    
    static let shared = SoundPlayer()
    
    private let session = AVAudioSession.sharedInstance()
    private let playQueue = DispatchQueue(label: "com.soundPlayer.playQueue", qos: .userInitiated)
    
    private var testSoundPlayer: AVAudioPlayer!
    private var soundPath: String { Bundle.main.path(forResource: "sound", ofType: "mp3")! }
    private var soundURL: URL { URL(fileURLWithPath: soundPath) }
    private var soundTimer: Timer?
    
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    
    override init() {
        super.init()
        do {
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            print(error)
        }
        do {
            testSoundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            testSoundPlayer.volume = 0
        } catch {
            print(error)
        }
        soundTimer = Timer(timeInterval: 43, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.testSoundPlayer.play()
        })
        RunLoop.main.add(soundTimer!, forMode: .common)
    }
    
}
