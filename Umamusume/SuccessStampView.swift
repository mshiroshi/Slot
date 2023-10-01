import SwiftUI
import AVFoundation

struct SuccessStampView: View {
    @ObservedObject var gameState: GameState
    @State private var isShow = true
    @State private var isBigStamp = true
    
    var clearTrainingBarFunction: () -> Void
    
    // 音
    private let stampSound = try! AVAudioPlayer(data: NSDataAsset(name: "stamp")!.data)
    
    var body: some View {
        if isShow && gameState.isAllTrainingUnitFinished == true {
            Image(gameState.isSuccessCurrentTrainingUnit == true ? "success" : "failure" )
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 150)
                .scaleEffect(isBigStamp ? 2.0 : 1.0)
                .animation(.linear(duration: 0.3), value: isBigStamp)
                .onAppear() {
                    isBigStamp = false
                    playStampSound()
                    
                    // 2秒後に非表示にする
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isBigStamp = true
                        gameState.isAllTrainingUnitFinished = nil
                        gameState.isSuccessCurrentTrainingUnit = nil
                        clearTrainingBarFunction()
                    }
                }
        }
    }
    
    private func playStampSound() {
        stampSound.stop()
        stampSound.currentTime = 0.0
        stampSound.play()
    }
}
