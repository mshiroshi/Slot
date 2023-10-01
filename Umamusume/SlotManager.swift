struct SlotManager {
    let slotState: SlotState
    let reelState1: ReelState
    let reelState2: ReelState
    let reelState3: ReelState
    
    func start() {
        let randomNum = Utility.randomNumber100()
        if randomNum <= 5 {
            startReach(isBingo: true)
        } else if randomNum <= 25 {
            startReach(isBingo: false)
        } else {
            startNotReach()
        }
    }
    
    func startDebug() {
        let randomNum = Utility.randomNumber100()
        if randomNum >= 1 && randomNum <= 33 {
            startReach(isBingo: true)
        } else if randomNum >= 34 && randomNum <= 66 {
            startReach(isBingo: false)
        } else {
            startNotReach()
        }
    }
    
    func startReach(isBingo: Bool) {
        if isBingo {
            let num = Utility.randomReelNumber()
            start(num1: num, num2: num, num3: num)
        } else {
            let num = Utility.randomReelNumber()
            let num2 = Utility.randomReelNumber(withoutNum: num)
            start(num1: num, num2: num2, num3: num)
        }
    }
    
    func startNotReach() {
        let num1 = Utility.randomReelNumber()
        let num2 = Utility.randomReelNumber(withoutNum: num1)
        let num3 = Utility.randomReelNumber(withoutNum1: num1, withoutNum2: num2)
        start(num1: num1, num2: num2, num3: num3)
    }
    
    func start(num1: Int, num2: Int, num3: Int) {
        print(String(num1) + "-" + String(num2) + "-" + String(num3))
        MusicManager.shared.playSlotStartSound()
        
        SlotController(reelNo: 1, slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3).start(finishNum: num1)
        SlotController(reelNo: 2, slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3).start(finishNum: num2)
        SlotController(reelNo: 3, slotState: slotState, reelState1: reelState1, reelState2: reelState2, reelState3: reelState3).start(finishNum: num3)
    }
}
