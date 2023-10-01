import SwiftUI

struct ContentView: View {
    // 保留玉
    var reserve = Reserve()
    
    var body: some View {
        VStack(spacing: 0) {
            TopView()
            SlotView(reserve: reserve)
            ReserveView(reserve: reserve)
            GameView(reserve: reserve)
            FooterView()
        }
        .background(
            Image("content_background")
            .resizable()
            .scaledToFill()
            .opacity(0.6)
        )
    }
}
