import SwiftUI
import AVKit

struct ReachPerformView: View {
    @StateObject var slotState: SlotState
    @StateObject var reelState1: ReelState
    @StateObject var reelState2: ReelState
    @StateObject var reelState3: ReelState
    
    @State private var avPlayer : AVPlayer?
    
    private let endPublisher = NotificationCenter.default.publisher(for: NSNotification.Name.AVPlayerItemDidPlayToEndTime)

    var body: some View {
        ZStack {
            VideoPlayer(player: avPlayer)
                .statusBarHidden()
                .onAppear {
                    // 演出を開始する
                    self.startReach()
                }
                .onReceive(endPublisher) { _ in
                    self.finishRearch()
                }
            
            // レースタイトルのキャクター画像
            if slotState.reachAction.reach.currentMovie?.type == .raceTitle, let race = slotState.reachAction.reach.race {
                VStack() {
                    HStack(spacing: 0) {
                        Image("ナビゲーター")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .offset(y: 20)
                        
                        BalloonText("\(race.characterName)が1着で\n大当たりです！", color: Color.white, mirrored: true)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .offset(y: 20)
                    }
                    
                    Image(race.characterImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 200)
                        .offset(x: 120)
                }
            }
            
            // レース中のアイコン画像
            if slotState.reachAction.isReachPerforming == true && slotState.reachAction.reach.currentMovie?.type == .race, let race = slotState.reachAction.reach.race {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Image(race.iconImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .offset(x: 5, y: 25)
                        Spacer()
                    }
                    Spacer()
                    
                    if let finishNum1 = reelState1.finishNum, let finishNum2 = reelState2.finishNum, let finishNum3 = reelState3.finishNum {
                        MiniSlotView(slotState: slotState, finishNum1: finishNum1, finishNum2: finishNum2, finishNum3: finishNum3)
                    }
                }
            }
            
        }
    }
    
    private func createReachAction() {
        let randomNum = Utility.randomNumber100()
        
        if self.isBingo() {
            slotState.reachAction.reach = Action(
                movies: [],
                speed: 10.0,
                race: Race(raceName: "有馬記念", characterName: "オグリキャップ", characterImageName: "キャラ_オグリキャップ", iconImageName: "アイコン_オグリキャップ")
            )
            var movies: [Movie] = []
            if Utility.randomNumber100() <= 10 {
                movies.append(Movie(name: "cm\(Utility.randomNumber(maxNum: 9))", type: .race))
            }
            movies.append(Movie(name: "有馬記念", type: .raceTitle))
            movies.append(Movie(name: "レース_序盤_オグリキャップ", type: .race))
            movies.append(Movie(name: "レース_中盤_オグリキャップ", type: .race))
            if Utility.randomNumber100() <= 30 {
                movies.append(Movie(name: "レース_バッドエンド_オグリキャップ", type: .race, result: .failure))
                movies.append(Movie(name: "レース_復活_オグリキャップ", type: .race))
            }
            movies.append(Movie(name: "レース_終盤_オグリキャップ", type: .race, result: .success))
            slotState.reachAction.reach.movies = movies
            
            slotState.reachAction.live = Action(
                movies: [Movie(name: "ライブ_ユメヲカケル", type: .live)]
            )
            slotState.reachAction.bonus = Action(
                movies: [Movie(name: "激熱", type: .bonus),
                         Movie(name: "ガチャ_ホッコータルマエ", type: .bonus)]
            )
        } else {
            if isNearpinReach() {
                slotState.reachAction.reach = Action(
                    movies: [Movie(name: "有馬記念", type: .raceTitle),
                             Movie(name: "レース_序盤_オグリキャップ", type: .race),
                             Movie(name: "レース_中盤_オグリキャップ", type: .race),
                             Movie(name: "レース_バッドエンド_オグリキャップ", type: .race, result: .failure)],
                    speed: 10.0,
                    race: Race(raceName: "有馬記念", characterName: "オグリキャップ", characterImageName: "キャラ_オグリキャップ", iconImageName: "アイコン_オグリキャップ")
                )
            } else {
                slotState.reachAction.reach = Action(
                    movies: [Movie(name: "cm\(Utility.randomNumber(maxNum: 9))", type: .cm)],
                    speed: 1.0
                )
            }
        }
    }
    
    private func clearReachAction() {
        slotState.reachAction = ReachAction()
    }
    
    private func startReach() {
        if slotState.reachAction.reach.isPlayed() == false {
            // 演出を決定する
            self.createReachAction()
            
            // リーチ演出を再生
            print("reach play")
            self.playAction(action: slotState.reachAction.reach)
            slotState.reachAction.isReachPerforming = true
            slotState.reachAction.reach.playedCount = 1
            return
        }
        
        // リーチ演出が再生済みであればライブ演出に進む
        print("live play")
        self.playAction(action: slotState.reachAction.live)
        slotState.reachAction.isReachPerforming = false
        slotState.reachAction.isLivePerformiming = true
        slotState.reachAction.live.playedCount = 1
    }
    
    private func finishRearch() {
        // ハズレだったら終了
        if isBingo() == false {
            if slotState.reachAction.reach.isAllPlayed() == false {
                // 次のリーチ演出を再生
                print("reach play")
                self.playAction(action: slotState.reachAction.reach)
                slotState.reachAction.reach.playedCount += 1
                return
            }
            
            MusicManager.shared.playNotBingoSound()
            
            // リールを正しい数字にする
            self.setSlotReel()
            
            // 全ての演出を終了する
            self.finallyReachAction()
            return
        }
        
        if slotState.reachAction.reach.isAllPlayed() == false {
            // 次のリーチ演出を再生
            print("reach play")
            self.playAction(action: slotState.reachAction.reach)
            slotState.reachAction.reach.playedCount += 1
            return
        }
        
        if slotState.reachAction.live.isPlayed() == false {
            // リールを正しい数字にする
            self.setSlotReel()
            
            // リーチ動画再生が終わったら、一旦揃ったリールを見せる
            slotState.isShowReachPerformView = false
            
            MusicManager.shared.playBingoSound()
            
            // 5秒後にライブ演出を開始
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                // Viewを切り替えてonAppearを発火する
                slotState.isShowReachPerformView = true
            }
            return
        }
        
        if slotState.reachAction.live.isAllPlayed() == false {
            // 次のライブ演出を再生
            print("live play")
            self.playAction(action: slotState.reachAction.live)
            slotState.reachAction.live.playedCount += 1
            return
        }
        
        if slotState.reachAction.bonus.isPlayed() == false {
            // ボーナス演出を再生
            print("bonus play")
            self.playAction(action: slotState.reachAction.bonus)
            slotState.reachAction.isLivePerformiming = false
            slotState.reachAction.isBonusPerforming = true
            slotState.reachAction.bonus.playedCount += 1
            return
        }
        
        if slotState.reachAction.bonus.isAllPlayed() == false {
            // 次のボーナス演出を再生
            print("bonus play")
            self.playAction(action: slotState.reachAction.bonus)
            slotState.reachAction.bonus.playedCount += 1
            return
        }
        
        slotState.reachAction.isBonusPerforming = false
        
        // 全ての演出を終了する
        self.finallyReachAction()
    }
    
    private func finallyReachAction() {
        self.avPlayer = nil
        
        // スロット画面を表示する
        slotState.isShowReachPerformView = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // 次のスロットを回せるようにする
            slotState.isSlotProcessing = false
            
            self.clearReachAction()
            
            MusicManager.shared.startTrainningBackMusic()
        }
    }
    
    private func isBingo() -> Bool {
        if reelState1.finishNum == reelState2.finishNum && reelState1.finishNum == reelState3.finishNum {
            return true
        }
        return false
    }
    
    private func isNearpinReach() -> Bool {
        guard let reelNum1 = reelState1.finishNum, let reelNum2 = reelState2.finishNum else { return false }
        if reelNum1 == reelNum2 + 1 || reelNum1 == reelNum2 - 1{
            return true
        } else if reelNum1 == 1 && reelNum2 == symbols.count {
            return true
        } else if reelNum1 == symbols.count && reelNum2 == 1 {
            return true
        }
        return false
    }
    
    private func playAction(action: Action) {
        let movieName = action.movies[action.playedCount].name
        self.avPlayer = AVPlayer(url: Bundle.main.url(forResource: movieName, withExtension: "mp4")!)
        
        if let player = self.avPlayer {
            player.play()
            player.rate = action.speed
        }
    }
    
    private func setSlotReel() {
        reelState1.reset(initIndex: reelState1.stopIndex!)
        reelState2.reset(initIndex: reelState2.stopIndex!)
        reelState3.reset(initIndex: reelState3.stopIndex!)
    }
}

struct ReachAction {
    var reach = Action()
    var live = Action()
    var bonus = Action()
    
    var isReachPerforming = false
    var isLivePerformiming = false
    var isBonusPerforming = false
}

struct Action {
    var movies: [Movie] = []
    var speed: Float = 1.0
    var playedCount = 0
    
    var race: Race?
                
    var currentMovie: Movie? {
        get {
            if movies.count == 0 {
                return nil
            }
            return movies[playedCount - 1]
        }
    }
    
    func isPlayed() -> Bool {
        return playedCount > 0
    }
    
    func isAllPlayed() -> Bool {
        return movies.count == playedCount
    }
}

struct Movie {
    var name: String
    var type: MovieType
    var result: MovieResult?
}

enum MovieType {
    case raceTitle
    case race
    case live
    case bonus
    case cm
}

enum MovieResult {
    case success
    case failure
}

struct Race {
    var raceName: String
    var characterName: String
    var characterImageName: String
    var iconImageName: String
}
