import SwiftUI
import AVFoundation

final public class MusicManager {
    public static let shared = MusicManager()
    private init() {}
    
    private let trainingBackMusic = try! AVAudioPlayer(data: NSDataAsset(name: "training_backmusic")!.data)
    private let reachBackMusic = try! AVAudioPlayer(data: NSDataAsset(name: "reach_backmusic")!.data)
    
    // リーチ
    private let reach1Sound = try! AVAudioPlayer(data: NSDataAsset(name: "reach1_sound")!.data)
    private let reach2Sound = try! AVAudioPlayer(data: NSDataAsset(name: "reach2_sound")!.data)
    private let reach3Sound = try! AVAudioPlayer(data: NSDataAsset(name: "reach3_sound")!.data)
    
    // 歓声
    private let cheersSound = try! AVAudioPlayer(data: NSDataAsset(name: "cheers_sound")!.data)
    
    // カンッ
    private let trainingStartSound = try! AVAudioPlayer(data: NSDataAsset(name: "training_start_sound")!.data)
    
    // シャキーン
    private let bingoSound = try! AVAudioPlayer(data: NSDataAsset(name: "bingo_sound")!.data)
    
    // ブオッ
    private let notBingoSound = try! AVAudioPlayer(data: NSDataAsset(name: "not_bingo_sound")!.data)
    
    // パカッ
    private let slotStartSound = try! AVAudioPlayer(data: NSDataAsset(name: "slot_start_sound")!.data)
    
    // ペタッ
    private let stepUpSound = try! AVAudioPlayer(data: NSDataAsset(name: "step_up_sound")!.data)
    
    // シャンシャン
    private let bellSound = try! AVAudioPlayer(data: NSDataAsset(name: "bell_sound")!.data)
    
    // シャン
    private let bellShortSound = try! AVAudioPlayer(data: NSDataAsset(name: "bell_short_sound")!.data)
    
    func startTrainningBackMusic() {
        trainingBackMusic.numberOfLoops = -1
        trainingBackMusic.currentTime = 0.0
        trainingBackMusic.play()
    }
    
    func stopTrainningBackMusic() {
        trainingBackMusic.stop()
    }
    
    func startReachBackMusic() {
        reachBackMusic.stop()
        reachBackMusic.currentTime = 0.0
        reachBackMusic.play()
    }
    
    func stopReachBackMusic() {
        reachBackMusic.stop()
    }
    
    func playReachSound() {
        let array = [1, 2, 3]
        switch array.randomElement()! {
        case 1:
            reach1Sound.stop()
            reach1Sound.currentTime = 0.0
            reach1Sound.play()
        case 2:
            reach2Sound.stop()
            reach2Sound.currentTime = 0.0
            reach2Sound.play()
        case 3:
            reach3Sound.stop()
            reach3Sound.currentTime = 0.0
            reach3Sound.play()
        default:
            return
        }
    }
    
    func playCheersSound(){
        cheersSound.stop()
        cheersSound.currentTime = 0.0
        cheersSound.play()
    }
    
    func playTrainingStartSound(){
        trainingStartSound.stop()
        trainingStartSound.currentTime = 0.0
        trainingStartSound.play()
    }
    
    func playBingoSound(){
        bingoSound.stop()
        bingoSound.currentTime = 0.0
        bingoSound.play()
    }
    
    func playNotBingoSound(){
        notBingoSound.stop()
        notBingoSound.currentTime = 0.0
        notBingoSound.play()
    }
    
    func playSlotStartSound(){
        slotStartSound.stop()
        slotStartSound.currentTime = 0.0
        slotStartSound.play()
    }
    
    func playStepUpSound(){
        stepUpSound.stop()
        stepUpSound.currentTime = 0.0
        stepUpSound.play()
    }
    
    func playBellSound(){
        bellSound.numberOfLoops = -1
        bellSound.currentTime = 0.0
        bellSound.play()
    }
    
    func stopBellSound(){
        bellSound.stop()
    }
    
    func playBellShortSound(){
        bellShortSound.stop()
        bellShortSound.currentTime = 0.0
        bellShortSound.play()
    }
}
