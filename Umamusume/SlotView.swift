import SwiftUI
import AVKit

// 定数
let reelImageSize: CGFloat = 100
let reelBaseOffset: CGFloat = reelImageSize * 1.5

// リールが止まるまでの最小秒数
private let reelStopMinSecond: Double = 5
// リーチ時に左右のリールが止まってから中央リールが止まるまでの秒数
private let reachPerformDelaySecond: Double = 5
// slotViewのフェードアウトにかかる秒数
private let slotViewFadeoutSecond: Double = 2

// 効果音
private let reelStopSound1 = try! AVAudioPlayer(data: NSDataAsset(name: "reel_stop_sound")!.data)
private let reelStopSound2 = try! AVAudioPlayer(data: NSDataAsset(name: "reel_stop_sound")!.data)
private let reelStopSound3 = try! AVAudioPlayer(data: NSDataAsset(name: "reel_stop_sound")!.data)

struct SlotView: View {
    // 保留玉
    @StateObject var reserve: Reserve
    // スロット起動タイマー
    @State var slotTimer: Timer!
    
    @StateObject var slotState = SlotState()
    @StateObject var reelState1 = ReelState(initIndex: Utility.randomReelNumber())
    @StateObject var reelState2 = ReelState(initIndex: Utility.randomReelNumber())
    @StateObject var reelState3 = ReelState(initIndex: Utility.randomReelNumber())
    
    // スロットエリアの高さ
    private let slotFrameHeight: CGFloat = 250

    var body: some View {
        // リーチ演出エリア
        if self.slotState.isShowReachPerformView {
            ReachPerformView(slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3)
                .frame(width: UIScreen.main.bounds.width, height: slotFrameHeight)
                .background(Color.black)
        } else {
            ZStack() {
                // 背景
                Image("slot_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: slotFrameHeight + 40)
                
                // SlotのFrame
                HStack {
                    ReelView(reelNo: 1, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3)
                    ReelView(reelNo: 2, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3)
                    ReelView(reelNo: 3, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3)
                }
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.3),
                                    Color.black.opacity(0.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 30)
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.0),
                                    Color.black.opacity(0.3)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 30)
                }
                .overlay(alignment: .center) {
                    Image("reach")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 120)
                        .offset(x: slotState.isSlideInReach ? 0 : UIScreen.main.bounds.width, y: 0)
                        .animation(.easeIn(duration: 0.2), value: slotState.isSlideInReach)
                        .offset(x: slotState.isSlideOutReach ? 0 - UIScreen.main.bounds.width : 0, y: 0)
                        .animation(.easeOut(duration: 0.4), value: slotState.isSlideOutReach)
                }
                .onAppear {
                    print("Timer Start")
                    slotTimer = Timer.scheduledTimer(withTimeInterval:1, repeats: true, block: { (time:Timer) in
                        self.startSlot()
                    })
                }
                .onDisappear {
                    print("Timer Stop")
                    slotTimer.invalidate()
                }
                
                // ステップアップ演出エリア
                if slotState.stepUpAction.isStepUpPerforming {
                    if let stepUpImage = slotState.stepUpAction.currentStepUpImage {
                        Image(stepUpImage.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 120)
                            .scaleEffect(stepUpImage.isShowing ? 1 : 0)
                            .animation(.linear(duration: stepUpImage.scaleSecond), value: stepUpImage.isShowing)
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: slotFrameHeight)
            .opacity(self.slotState.isFadeoutSlotView ? 0 : 1)
            .transition(.opacity)
            .animation(.linear(duration: slotViewFadeoutSecond), value: self.slotState.isFadeoutSlotView)
            .overlay(alignment: .center) {
                GeometryReader { geometry in
                    ParticleView(fileNames: ["RainShortRight", "RainShortLeft"], size: geometry.size)
                        .opacity(slotState.isFadeInShortParticle ? 1 : 0)
                        .transition(.opacity)
                        .animation(.linear(duration: 0.5), value: slotState.isFadeInShortParticle)
                }
            }
            .overlay(alignment: .center) {
                GeometryReader { geometry in
                    ParticleView(fileNames: ["RainRight"], size: geometry.size)
                        .opacity(slotState.isFadeInParticle ? 1 : 0)
                        .transition(.opacity)
                        .animation(.linear(duration: 1), value: slotState.isFadeInParticle)
                }
            }

        }
    }
    
    private func startSlot() {
        if slotState.isSlotProcessing == false {
            // 保留玉があればスロットを回す
            if reserve.units.isEmpty == false {
                // 保留玉が追加されてから3秒以上経過している場合
                let currentDateTime = Date()
                if let createDateTime = Calendar.current.date(byAdding: .second, value: 3, to: reserve.units.first!.createDateTime), currentDateTime > createDateTime {
                    
                    print("Start Slot")
                    slotState.isSlotProcessing = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        // 保留玉を減らす
                        reserve.remove()
                        
                        // スロットを回す
                        // TODO:
                        let slotManager = SlotManager(slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3)
                        slotManager.start()
                        //slotManager.startReach(isBingo: true)
                        //slotManager.startNotReach()
                        //slotManager.startDebug()
                        
                        // ステップアップ演出
                        self.performStepUpAction()
                    }
                }
            }
        }
    }
    
    private func isReach() -> Bool {
        if (reelState1.stopDateTime != nil && reelState2.stopDateTime == nil && reelState3.stopDateTime != nil)
            && reelState1.finishNum == reelState3.finishNum {
            return true
        }
        return false
    }
    
    private func isBingo() -> Bool {
        if reelState1.finishNum == reelState2.finishNum && reelState1.finishNum == reelState3.finishNum {
            return true
        }
        return false
    }
    
    private func createStepUpAction() {
        let randomNum = Utility.randomNumber100()
        //let randomNum = 25
        
        if self.isBingo() {
            if randomNum <= 20 {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ"),
                        StepUpImage(imageName: "ステップ2_オグリキャップ"),
                        StepUpImage(imageName: "ステップ3_オグリキャップ", showSecond: 5)
                    ]
                )
            } else if randomNum <= 23 {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ"),
                        StepUpImage(imageName: "ステップ2_オグリキャップ")
                    ]
                )
            } else if randomNum == 100 {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ")
                    ]
                )
            }
        } else if self.isReach() {
            if randomNum <= 30  {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ")
                    ]
                )
            } else if randomNum <= 45 {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ"),
                        StepUpImage(imageName: "ステップ2_オグリキャップ")
                    ]
                )
            } else if randomNum >= 98 {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ"),
                        StepUpImage(imageName: "ステップ2_オグリキャップ"),
                        StepUpImage(imageName: "ステップ3_オグリキャップ", showSecond: 5)
                    ]
                )
            }
        } else {
            if randomNum <= 20  {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ")
                    ]
                )
            } else if randomNum <= 25 {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ"),
                        StepUpImage(imageName: "ステップ2_オグリキャップ")
                    ]
                )
            } else if randomNum == 100 {
                slotState.stepUpAction = StepUpAction(
                    stepUpImages: [
                        StepUpImage(imageName: "ステップ1_オグリキャップ"),
                        StepUpImage(imageName: "ステップ2_オグリキャップ"),
                        StepUpImage(imageName: "ステップ3_オグリキャップ", showSecond: 5)
                    ]
                )
            }
        }
    }
    
    private func performStepUpAction() {
        self.createStepUpAction()
        
        if slotState.stepUpAction.stepUpImages.isEmpty {
            return
        }
        
        slotState.stepUpAction.isStepUpPerforming = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // 1つ目のステップアップ画像を表示する
            slotState.stepUpAction.showCount = 1
            slotState.stepUpAction.currentStepUpImage?.isShowing = true
            
            self.doStepUpAction()
        }
    }
    
    private func doStepUpAction() {
        guard let currentStepUpImage = slotState.stepUpAction.currentStepUpImage else { return }
        
        MusicManager.shared.playStepUpSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentStepUpImage.showSecond) {
            withAnimation {
                slotState.stepUpAction.currentStepUpImage?.isShowing = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + currentStepUpImage.scaleSecond) {
                // ステップアップを終了
                if slotState.stepUpAction.isFinish() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        slotState.stepUpAction.isStepUpPerforming = false
                    }
                    return
                }
                
                // 次のステップアップ画像を表示する
                slotState.stepUpAction.showCount += 1
                slotState.stepUpAction.currentStepUpImage?.isShowing = true
                
                self.doStepUpAction()
            }
        }
    }

}

class SlotState: ObservableObject {
    // UIと紐付けたいので @Published
    @Published var isFadeInParticle = false // particleの表示に使用
    @Published var isFadeInShortParticle = false // particleの表示に使用
    @Published var isFadeoutSlotView = false // slotViewのフェードアウトに使用
    @Published var isSlideInReach = false // リーチのスライドインに使用
    @Published var isSlideOutReach = false // リーチのスライドアウトに使用
    @Published var isShowReachPerformView = false // ReachPerformViewの切り替えに使用
    var isDidReach = false // リーチ処理を一度だけ実行する処理を制御するためのフラグ
    var isSlotProcessing = false // タイマーでスロットを１回ずつ実行する処理を制御するためのフラグ
    
    // リーチアクションの定義
    var reachAction = ReachAction()
    
    // ステップアップの定義
    var stepUpAction = StepUpAction()
}

struct SlotController {
    private let reelNo: Int
    private let slotState: SlotState
    private let reelState1: ReelState
    private let reelState2: ReelState
    private let reelState3: ReelState
    
    // コンストラクタで指定されたリール
    private let reelState: ReelState
    
    // はやく回転するときのスピード
    let reelDurationFast = 0.1
    // ゆっくり回転するときのスピード
    let reelDurationSlow = 0.5
    
    init(reelNo: Int, slotState: SlotState, reelState1: ReelState, reelState2: ReelState, reelState3: ReelState) {
        self.slotState = slotState
        self.reelState1 = reelState1
        self.reelState2 = reelState2
        self.reelState3 = reelState3
        
        self.reelNo = reelNo
        switch reelNo {
        case 1:
            self.reelState = reelState1
        case 2:
            self.reelState = reelState2
        case 3:
            self.reelState = reelState3
        default:
            // コンパイルエラー対応（この処理に入ることはない）
            exit(0)
        }
    }
    
    func start(finishNum: Int) {
        reelState.finishNum = finishNum
        reelState.stopIndex = nil
        reelState.stopDateTime = nil
        slotState.isDidReach = false
        
        // Particle(Short)
        if self.isReach() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + reelStopMinSecond / 2) {
                slotState.isFadeInShortParticle = true
                MusicManager.shared.playBellShortSound()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    slotState.isFadeInShortParticle = false
                }
            }
        }
        
        loop()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + reelStopMinSecond) {
            stop(num: finishNum)
        }
    }

    private func loop() {
        // 回転を続ける
        spinReel() {
            if canStop() {
                // canStop()がtrueになるとループを抜ける
                didStop()
            } else if canReach() {
                // canReach()がtrueになるとdidReach()を1回実行する（ループは抜けない）
                didReach()
                // 再帰呼び出し
                loop()
            } else if slotState.isShowReachPerformView == true {
                // リーチ演出が始まったらループを抜ける
            } else {
                // 再帰呼び出し
                loop()
            }
        }
    }

    private func getDuration(toIndex: Int) -> Double {
        // ステップアップ演出中は回り続ける
        if slotState.stepUpAction.isStepUpPerforming == true {
            return reelDurationFast
        }
        // 真ん中のリールは左右のリールが止まるまで高速で回り続ける（リーチの場合は回り続ける）
        if reelNo == 2 {
            if self.isReach() {
                return reelDurationFast
            }
            if self.isEnableStopCenterReel() == false {
                return reelDurationFast
            }
        }
        return reelState.stopIndex == toIndex ? reelDurationSlow : reelDurationFast
    }

    private func spinReel(completion: @escaping () -> Void) {
        // 現在の index を取得
        let oldIndex = reelState.index
        var newIndex = oldIndex + 1
        // index の限界を超えていた場合は内部保持のデータのみ 0 にする
        let maxIndex = symbols.count - 1
        if newIndex > maxIndex {
            newIndex = 0
        }
        let oldOffset = CGFloat(symbols.count - oldIndex - 1) * reelImageSize + reelBaseOffset
        let newOffset = oldOffset - reelImageSize
        // 時間をかけて値を変化させる
        let d = getDuration(toIndex: newIndex)
        DispatchQueue.main.async {
            reelState.index = newIndex
            reelState.offset = oldOffset
            withAnimation(.linear(duration: d)) {
                reelState.offset = newOffset
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + d) {
            completion()
        }
    }

    private func canStop() -> Bool {
        // ステップアップ演出中は止めない
        if slotState.stepUpAction.isStepUpPerforming == true {
            return false
        }
        // 真ん中のリールは左右のリールが止まってから一定時間経過してからでないと止まらないようにする（但しリーチ時は止めない）
        if reelNo == 2 {
            if self.isReach() {
                return false
            }
            if self.isEnableStopCenterReel() == false {
                return false
            }
        }

        return reelState.stopIndex == reelState.index
    }
    
    private func canReach() -> Bool {
        // リーチ演出中はfalse
        if slotState.isDidReach == true {
            return false
        }
        if reelNo == 2 && self.isReach() && reelState.stopDateTime == nil {
            print("canReach = true")
            return true
        }
        return false
    }
    
    private func isEnableStopCenterReel() -> Bool {
        guard let stopDateTime1 = reelState1.stopDateTime, let stopDateTime3 = reelState3.stopDateTime else { return false }
        
        let currentDateTime = Date()
        if currentDateTime > Calendar.current.date(byAdding: .second, value: 1, to: stopDateTime1)!
            && currentDateTime > Calendar.current.date(byAdding: .second, value: 1, to: stopDateTime3)! {
            return true
        }
        return false
    }

    private func stop(num: Int) {
        print("Reel-\(reelNo) Called stop")
        reelState.stopIndex = num - 1
    }

    private func didStop() {
        print("Reel-\(reelNo) Called didStop")
        // 止まる音
        playStopSound()
        
        reelState.stopDateTime = Date()
        
        // アニメーション用
        reelState.isSmallForAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            reelState.isSmallForAnimation = false
            
            if reelNo == 2 && self.isReach() == false {
                self.finishNoReach()
            }
        }
    }
    
    private func finishNoReach() {
        print("finishNoReach")
        // 次のスロットを回せるようにする
        slotState.isSlotProcessing = false
    }
    
    private func didReach() {
        print("Reel-\(reelNo) Called didReach")
        slotState.isDidReach = true
        
        var particleDelaySecond: Double =  0
        
        // 確率でパーティクル演出
        if isBingo() && Utility.randomNumber100() <= 60 {
            particleDelaySecond =  5
            slotState.isFadeInParticle = true
            MusicManager.shared.playBellSound()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + particleDelaySecond) {
            MusicManager.shared.stopBellSound()
            slotState.isFadeInParticle = false
            
            MusicManager.shared.stopTrainningBackMusic()
            MusicManager.shared.playReachSound()
            MusicManager.shared.startReachBackMusic()
            
            // リーチ画像をスライドイン
            slotState.isSlideInReach = true
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + reachPerformDelaySecond) {
                // リーチ画像をスライドアウト
                slotState.isSlideOutReach = true
                
                // slotViewをフェードアウト
                slotState.isFadeoutSlotView = true
                MusicManager.shared.playCheersSound()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + slotViewFadeoutSecond) {
                    // slotViewを元に戻しておく
                    slotState.isFadeoutSlotView = false
                    
                    // リーチ画像を元に戻しておく
                    slotState.isSlideInReach = false
                    slotState.isSlideOutReach = false
                    
                    // リーチ演出開始
                    slotState.isShowReachPerformView = true
                    
                    MusicManager.shared.stopReachBackMusic()
                }
            }
        }
    }
    
    private func isReach() -> Bool {
        if (reelState1.stopDateTime != nil && reelState3.stopDateTime != nil) && reelState1.stopIndex == reelState3.stopIndex {
            return true
        }
        return false
    }
    
    private func isBingo() -> Bool {
        if reelState1.finishNum == reelState2.finishNum && reelState1.finishNum == reelState3.finishNum {
            return true
        }
        return false
    }
    
    private func playStopSound(){
        switch reelNo {
        case 1:
            reelStopSound1.stop()
            reelStopSound1.currentTime = 0.0
            reelStopSound1.play()
        case 2:
            reelStopSound2.stop()
            reelStopSound2.currentTime = 0.0
            reelStopSound2.play()
        case 3:
            reelStopSound3.stop()
            reelStopSound3.currentTime = 0.0
            reelStopSound3.play()
        default:
            break
        }
    }
}

struct StepUpAction {
    var stepUpImages: [StepUpImage] = []
    
    var showCount = 0

    var isStepUpPerforming = false
    
    var currentStepUpImage: StepUpImage? {
        get {
            if stepUpImages.count == 0 || showCount == 0 {
                return nil
            }
            return stepUpImages[showCount - 1]
        }
        
        set(stepUpImage){
            stepUpImages[showCount - 1] = stepUpImage!
        }
    }
    
    func isFinish() -> Bool {
        return showCount == stepUpImages.count
    }
}

struct StepUpImage {
    let imageName: String
    var showSecond: Double = 3
    var scaleSecond: Double = 0.5
    var isShowing = true
}
