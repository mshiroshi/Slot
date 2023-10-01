import SwiftUI

// 定数
private let miniReelImageSize: CGFloat = 30
private let miniReelBaseOffset: CGFloat = miniReelImageSize * 1.5

// リールが止まるまでの最小秒数
private let miniReelStopMinSecond: Double = 10

struct MiniSlotView: View {
    @StateObject var slotState: SlotState
    var finishNum1: Int
    var finishNum2: Int
    var finishNum3: Int
    
    @StateObject var reelState1 = MiniReelState(initIndex: Utility.randomReelNumber())
    @StateObject var reelState2 = MiniReelState(initIndex: Utility.randomReelNumber())
    @StateObject var reelState3 = MiniReelState(initIndex: Utility.randomReelNumber())

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                MiniReelView(reelNo: 1, reelState: reelState1)
                MiniReelView(reelNo: 2, reelState: reelState2)
                MiniReelView(reelNo: 3, reelState: reelState3)
            }
            .offset(x: -5, y: 25)
            .onAppear {
                self.startSlot()
            }
            
            Spacer()
        }
    }
    
    private func startSlot() {
        // リール1
        reelState1.reset(initIndex: finishNum1 - 1)
        // リール2
        MiniSlotController(slotState: slotState, reelState2: reelState2).start(finishNum: finishNum2)
        // リール3
        reelState3.reset(initIndex: finishNum3 - 1)
    }
}

struct MiniReelView: View {
    let reelNo: Int
    @StateObject var reelState: MiniReelState

    private func square(_ symbol: Int) -> some View {
        return Image("num" + String(symbol))
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fill)
            .frame(width: miniReelImageSize, height: miniReelImageSize)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) { // squareとsquareの間が開かないようにspacing=0にする
                // ループ用に末尾2つ
                square(Array(symbols.prefix(2)).last!)
                square(Array(symbols.prefix(1)).last!)
                // リールの本体部分
                ForEach(symbols.reversed(), id: \.self) { symbol in
                    square(symbol)
                }
                // ループ用に先頭2つ
                square(Array(symbols.suffix(1)).first!)
                square(Array(symbols.suffix(2)).first!)
            }
            .offset(.init(width: 0, height: 0 - getOffset())) // 上からoffsetを計算したのでマイナス補正
        }
        .frame(width: miniReelImageSize, height: miniReelImageSize * 2)
        .background(Color.white.opacity(0.3))
    }
    
    private func getOffset() -> CGFloat {
        return reelState.offset
    }
}

struct MiniSlotController {
    private let slotState: SlotState
    // コンストラクタで指定されたリール
    private let reelState: MiniReelState
    
    // はやく回転するときのスピード
    let reelDurationFast = 0.1
    // ゆっくり回転するときのスピード
    let reelDurationSlow = 3.0
    
    init(slotState: SlotState, reelState2: MiniReelState) {
        self.slotState = slotState
        self.reelState = reelState2
    }
    
    func start(finishNum: Int) {
        reelState.stopIndex = nil
        reelState.stopDateTime = nil
        loop()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + miniReelStopMinSecond) {
            stop(num: finishNum)
        }
    }

    private func loop() {
        // 回転を続ける
        spinReel() {
            if canStop() {
                // canStop()がtrueになるとループを抜ける
                didStop()
            } else {
                // 再帰呼び出し
                loop()
            }
        }
    }

    private func getDuration(toIndex: Int) -> Double {
        // リーチ演出中
        if slotState.reachAction.isReachPerforming {
            if let result = slotState.reachAction.reach.currentMovie?.result {
                // result=failure、かつisAllPlayed=falseの場合はゆっくり
                if result == .failure && slotState.reachAction.reach.isAllPlayed() == false {
                    return reelDurationSlow
                }
            } else {
                // resultが設定されている動画以外はリールは高速
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
        let oldOffset = CGFloat(symbols.count - oldIndex - 1) * miniReelImageSize + miniReelBaseOffset
        let newOffset = oldOffset - miniReelImageSize
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
        // リーチ演出中
        if slotState.reachAction.isReachPerforming {
            if let result = slotState.reachAction.reach.currentMovie?.result {
                // result=failureかつisAllPlayed=falseの場合は止めない
                if result == .failure && slotState.reachAction.reach.isAllPlayed() == false {
                    return false
                }
            } else {
                // resultが設定されている動画以外はリールは止めない
                return false
            }
        }
        return reelState.stopIndex == reelState.index
    }

    private func stop(num: Int) {
        print("MiniReel-2 Called stop")
        reelState.stopIndex = num - 1
    }

    private func didStop() {
        print("MiniReel-2 Called didStop")
        reelState.stopDateTime = Date()
    }
}

class MiniReelState: ObservableObject {
    // UIと紐付けたいので @Published
    @Published var offset: CGFloat
    var index: Int
    var stopIndex: Int? = nil
    var stopDateTime: Date? = nil
    
    init(initIndex: Int) {
        self.index = initIndex
        offset = CGFloat((symbols.count - initIndex - 1)) * miniReelImageSize + miniReelBaseOffset
    }
    
    func reset(initIndex: Int) {
        self.index = initIndex
        offset = CGFloat((symbols.count - initIndex - 1)) * miniReelImageSize + miniReelBaseOffset
    }
}
