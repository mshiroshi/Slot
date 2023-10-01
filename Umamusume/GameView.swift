import SwiftUI

// 定数
private let stopButtonSize: CGFloat = 10

struct GameView: View {
    // 保留玉
    @StateObject var reserve: Reserve
    
    @State private var trainingUnitState1 = TrainingUnitState()
    @State private var trainingUnitState2 = TrainingUnitState()
    @State private var trainingUnitState3 = TrainingUnitState()
    @State private var trainingUnitState4 = TrainingUnitState()
    @State private var trainingUnitState5 = TrainingUnitState()
    @State private var trainingUnitStep: Int = 0
    @State private var disabledTrainingStartButton = false
    @State private var gameState = GameState()
    
    var body: some View {
        VStack {
            DescriptionView(gameState: gameState)
            
            ZStack {
                VStack(spacing: 10) {
                    TrainingUnitView(trainingType: .speed, state: trainingUnitState1, trainingStep: $trainingUnitStep, finishTrainingUnitFunction: finishTrainingUnit, nextTrainingUnitFunction: doNextTraining)
                    TrainingUnitView(trainingType: .stamina, state: trainingUnitState2, trainingStep: $trainingUnitStep, finishTrainingUnitFunction: finishTrainingUnit, nextTrainingUnitFunction: doNextTraining)
                    TrainingUnitView(trainingType: .power, state: trainingUnitState3, trainingStep: $trainingUnitStep, finishTrainingUnitFunction: finishTrainingUnit, nextTrainingUnitFunction: doNextTraining)
                    TrainingUnitView(trainingType: .guts, state: trainingUnitState4, trainingStep: $trainingUnitStep, finishTrainingUnitFunction: finishTrainingUnit, nextTrainingUnitFunction: doNextTraining)
                    TrainingUnitView(trainingType: .clever, state: trainingUnitState5, trainingStep: $trainingUnitStep, finishTrainingUnitFunction: finishTrainingUnit, nextTrainingUnitFunction: doNextTraining)
                }
                .padding(15)
                .background(
                    Image("training_background")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .opacity(0.6)
                )
                
                SuccessStampView(gameState: gameState, clearTrainingBarFunction: clearTrainingBar)
            }
            
            Text("\(gameState.turn)/\(gameState.maxTurn)　Score:\(gameState.score)")
                .frame(maxWidth: .infinity, alignment: .trailing)

            // ボタンView
            ZStack {
                if trainingUnitStep >= 1 && trainingUnitStep <= 5 {
                    Button(action: {
                        stopButtonAction()
                    }){
                        Image(getStopButtonName(trainingStep: trainingUnitStep))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                    }
                    
                } else {
                    
                    Button(action: {
                        // 最初からトレーニングを開始する
                        initTraining()
                    }) {
                        Text("トレーニング開始")
                            .fontWeight(.black)
                            .frame(width: 160, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .accentColor(Color.white)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(UIColor(red: 141/255, green: 209/255, blue: 68/255, alpha: 1.0)),
                            Color(UIColor(red: 100/255, green: 148/255, blue: 48/255, alpha: 1.0))
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .cornerRadius(10)
                    .shadow(color: Color.gray, radius: 2, x: 1, y: 2)
                    .disabled(disabledTrainingStartButton)
                }
            }
            .frame(height: 50)
            
            Spacer()
        }
        .onAppear() {
            MusicManager.shared.startTrainningBackMusic()
        }
    }
    
    private func stopButtonAction() {
        switch trainingUnitStep {
        case 1:
            trainingUnitState1.isStopped = true
        case 2:
            trainingUnitState2.isStopped = true
        case 3:
            trainingUnitState3.isStopped = true
        case 4:
            trainingUnitState4.isStopped = true
        case 5:
            trainingUnitState5.isStopped = true
        default:
            break
        }
    }
    
    private func finishTrainingUnit() {
        // まだトレーニングが終わってなかったら何もしない
        // (トレーニング途中の場合はisTrainingUnitSuccess()はnilを返す)
        guard let isSuccess = isTrainingUnitSuccess() else {
            return
        }
        
        // トレーニングが成功
        if isSuccess == true {
            gameState.isSuccessCurrentTrainingUnit = true
            // スコアに足す
            gameState.score += 100
            // 保留玉に足す
            reserve.add()
        }
                
        // トレーニング途中で成功or失敗が判定された場合があるのでステップを9(完了)にする
        trainingUnitStep = 9
        
        gameState.isAllTrainingUnitFinished = true
        
        // 全トレーニングが終わっていたらトレーニング開始ボタンを押せるようにする
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 全ターン終了であればゲームを初期化する
            if gameState.turn == gameState.maxTurn {
                initGame()
                return
            }
            
            disabledTrainingStartButton = false
            
            // ターンを+1する
            gameState.turn += 1
        }
    }
    
    private func isTrainingUnitSuccess() -> Bool? {
        let rule = TrainingRule.get(ruleId: gameState.getCurrentRuleId())
        let isValid = rule.isValid(trainingUnitState1.resultPoint, trainingUnitState2.resultPoint, trainingUnitState3.resultPoint, trainingUnitState4.resultPoint, trainingUnitState5.resultPoint)
        if let valid = isValid {
            print("TrainningUnit(\(trainingUnitStep)) isValid=\(valid)")
        } else {
            print("TrainningUnit(\(trainingUnitStep)) isValid=nil")
        }
        return isValid
    }
    
    private func initGame() {
        gameState = GameState()
        disabledTrainingStartButton = false
    }
    
    private func initTraining() {
        clearTrainingBar()
        trainingUnitStep = 0
        gameState.isAllTrainingUnitFinished = false
        disabledTrainingStartButton = true
        
        MusicManager.shared.playTrainingStartSound()
        
        doNextTraining()
    }
    
    private func clearTrainingBar() {
        trainingUnitState1 = TrainingUnitState()
        trainingUnitState2 = TrainingUnitState()
        trainingUnitState3 = TrainingUnitState()
        trainingUnitState4 = TrainingUnitState()
        trainingUnitState5 = TrainingUnitState()
    }
    
    private func doNextTraining() {
        // 次のトレーニングへ
        if trainingUnitStep == 0 {
            // スピードトレーニングへ
            trainingUnitStep = TrainingType.speed.rawValue
            trainingUnitState1 = TrainingUnitState()
        } else if trainingUnitStep == TrainingType.speed.rawValue {
            // スタミナトレーニングへ
            trainingUnitStep = TrainingType.stamina.rawValue
            trainingUnitState2 = TrainingUnitState()
        } else if trainingUnitStep == TrainingType.stamina.rawValue {
            // パワートレーニングへ
            trainingUnitStep = TrainingType.power.rawValue
            trainingUnitState3 = TrainingUnitState()
        } else if trainingUnitStep == TrainingType.power.rawValue {
            // 根性トレーニングへ
            trainingUnitStep = TrainingType.guts.rawValue
            trainingUnitState4 = TrainingUnitState()
        } else if trainingUnitStep == TrainingType.guts.rawValue {
            // 賢さトレーニングへ
            trainingUnitStep = TrainingType.clever.rawValue
            trainingUnitState5 = TrainingUnitState()
        } else if trainingUnitStep == TrainingType.clever.rawValue {
            trainingUnitStep = 9
        }
    }
    
    private func getStopButtonName(trainingStep: Int) -> String {
        switch trainingStep {
        case 1:
            return "speed1"
        case 2:
            return "stamina1"
        case 3:
            return "power1"
        case 4:
            return "guts1"
        case 5:
            return "clever1"
        default:
            return ""
        }
    }
}

enum TrainingResult {
    case failure
    case smallSuccess
    case bigSuccess
    case perfectSuccess
}

enum TrainingType: Int {
    case speed = 1
    case stamina = 2
    case power = 3
    case guts = 4
    case clever = 5
}

class TrainingUnitState: ObservableObject {
    @Published var rectangleWidth: CGFloat = 0.0
    @Published var isStopped = false // すぐに開始するのでfalse
    var resultPoint: Int? = nil
}

class GameState: ObservableObject {
    @Published var turn: Int = 1
    var maxTurn: Int = 2
    var ruleIdList: [Int] = []
    @Published var score: Int = 0
    @Published var isAllTrainingUnitFinished: Bool?
    @Published var isSuccessCurrentTrainingUnit: Bool?
    
    init() {
        // トレーニングを決定
        var trainingRuleIdList = TrainingRule.getRuleIdList()
        while true {
            if self.ruleIdList.count == maxTurn {
                break
            }
            if let trainingRuleId = trainingRuleIdList.randomElement() {
                self.ruleIdList.append(trainingRuleId)
                trainingRuleIdList.removeAll(where: {$0 == trainingRuleId})
            }
        }
    }
    
    func getCurrentRuleId() -> Int {
        return ruleIdList[turn - 1]
    }
}
