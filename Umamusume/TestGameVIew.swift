import SwiftUI

struct TestGameView: View {
    
    var body: some View {
        VStack {
            Button(action: {
                self.startSlot()
            }) {
                Text("スロットを回す")
                    .fontWeight(.semibold)
                    .frame(width: 200, height: 50)
                    .foregroundColor(Color(.white))
                    .background(Color(UIColor.systemGreen))
                    .cornerRadius(24)
            }
        }
        //.frame(width: .infinity, height: 600)
    }
    
    private func startSlot() {
        let slotState = SlotState()
        let reelState1 = ReelState(initIndex: 1)
        let reelState2 = ReelState(initIndex: 2)
        let reelState3 = ReelState(initIndex: 3)
        
        SlotController(reelNo: 1, slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3).start(finishNum: Utility.randomReelNumber())
        SlotController(reelNo: 2, slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3).start(finishNum: Utility.randomReelNumber())
        SlotController(reelNo: 3, slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3).start(finishNum: Utility.randomReelNumber())
    }
}
