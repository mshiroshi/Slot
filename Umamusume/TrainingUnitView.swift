import SwiftUI
import AVFoundation

// 音楽
private let trainingStopSound = try!  AVAudioPlayer(data: NSDataAsset(name: "training_stop_sound")!.data)

struct TrainingUnitView: View {
    var trainingType: TrainingType
    @ObservedObject var state: TrainingUnitState
    @Binding var trainingStep: Int
   
    var finishTrainingUnitFunction: () -> Void
    var nextTrainingUnitFunction: () -> Void
    
    var body: some View {
        HStack {
            Image(getTrainingImageName())
                .resizable()
                .scaledToFit()
                .frame(width:25, height:25)
            
            // トレーニングバー
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: self.getMaxTrainingWidth(), height: 16)
                    .foregroundColor(Color(UIColor.lightGray))
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(.white, lineWidth: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(.gray, lineWidth: 2)
                    )
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [getTrainingColor().opacity(1.0), getTrainingColor().opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: state.rectangleWidth, height: 12, alignment: .leading)
                    .cornerRadius(30)
            }
            
            Spacer()
            
            // ラベル
            Text("\(self.getTrainingPoint())")
                .foregroundColor(.brown)
                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)))
            
        }
        .onReceive(state.$isStopped, perform: { isStopped in
            if trainingType.rawValue == trainingStep {
                if isStopped {
                    stop()
                } else {
                    loop()
                }
            }
        })
    }
    
    private func getMaxTrainingWidth() -> CGFloat {
        return UIScreen.main.bounds.width - 120
    }
    
    private func getTrainingPoint() -> Int {
        return Int(state.rectangleWidth / self.getMaxTrainingWidth() * 100)
    }
    
    private func getTrainingColor() -> Color {
        switch trainingType {
        case .speed:
            return Color.blue
        case .stamina:
            return Color.red
        case .power:
            return Color.orange
        case .guts:
            return Color(UIColor.magenta)
        case .clever:
            return Color.green
        }
    }
    
    private func getTrainingImageName() -> String {
        switch trainingType {
        case .speed:
            return "speed"
        case .stamina:
            return "stamina"
        case .power:
            return "power"
        case .guts:
            return "guts"
        case .clever:
            return "clever"
        }
    }
    
    private func loop() {
        expandRectangle() {
            if canStop() {
                didStop()
            } else {
                // 再帰呼び出し
                loop()
            }
        }
    }
    
    private func expandRectangle(completion: @escaping () -> Void) {
        // 時間をかけて値を変化させる
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.2)) {
                let trainingPoint = getTrainingPoint()
                if trainingPoint <= 40 {
                    let randomInt = Int.random(in: 8..<10)
                    state.rectangleWidth += CGFloat(randomInt)
                } else if trainingPoint <= 60 {
                    let randomInt = Int.random(in: 7..<10)
                    state.rectangleWidth += CGFloat(randomInt)
                } else if trainingPoint <= 70 {
                    let randomInt = Int.random(in: 8..<11)
                    state.rectangleWidth += CGFloat(randomInt)
                } else if trainingPoint <= 80 {
                    let randomInt = Int.random(in: 8..<12)
                    state.rectangleWidth += CGFloat(randomInt)
                } else if trainingPoint <= 90 {
                    let randomInt = Int.random(in: 9..<12)
                    state.rectangleWidth += CGFloat(randomInt)
                } else {
                    let randomInt = Int.random(in: 10..<12)
                    state.rectangleWidth += CGFloat(randomInt)
                    // 最大は100になるようにする
                    if state.rectangleWidth > self.getMaxTrainingWidth() {
                        state.rectangleWidth = self.getMaxTrainingWidth()
                        state.isStopped = true
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
        }
    }
    
    private func canStop() -> Bool {
        // ストップボタンが押された場合
        if state.isStopped {
            return true
        }
        return false
    }
    
    private func stop() {
        // 結果を保存する
        state.resultPoint = getTrainingPoint()
        
        playStopSound()
    }
    
    private func didStop() {
        // TrainningUtit終了処理を実行する
        self.finishTrainingUnitFunction()
        
        // 次のトレーニングを開始
        self.nextTrainingUnitFunction()
    }
    
    private func playStopSound(){
        trainingStopSound.stop()
        trainingStopSound.currentTime = 0.0
        trainingStopSound.play()
    }
}
