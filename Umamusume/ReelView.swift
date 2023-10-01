import SwiftUI
import AVKit

struct ReelView: View {
    let reelNo: Int
    @StateObject var reelState1: ReelState
    @StateObject var reelState2: ReelState
    @StateObject var reelState3: ReelState

    private func square(_ symbol: Int) -> some View {
        return Image("num" + String(symbol))
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fill)
            .frame(width: reelImageSize, height: reelImageSize)
            .scaleEffect(currentReelState().isSmallForAnimation && currentReelState().finishNum == symbol ? 0.9 : 1)
            .animation(.linear(duration: 0.1), value: currentReelState().isSmallForAnimation)
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
        .frame(width: reelImageSize, height: reelImageSize * 2)
        .background(Color.white.opacity(0.3))
    }
    
    private func currentReelState() -> ReelState {
        switch self.reelNo {
        case 1:
            return reelState1
        case 2:
            return reelState2
        case 3:
            return reelState3
        default:
            exit(0)
        }
    }
    
    private func getOffset() -> CGFloat {
        return currentReelState().offset
    }
}

class ReelState: ObservableObject {
    // UIと紐付けたいので @Published
    @Published var offset: CGFloat
    var index: Int
    var finishNum: Int? = nil
    var stopIndex: Int? = nil
    var stopDateTime: Date? = nil
    var isSmallForAnimation = false
    
    init(initIndex: Int) {
        self.index = initIndex
        offset = CGFloat((symbols.count - initIndex - 1)) * reelImageSize + reelBaseOffset
    }
    
    func reset(initIndex: Int) {
        self.index = initIndex
        offset = CGFloat((symbols.count - initIndex - 1)) * reelImageSize + reelBaseOffset
    }
}
