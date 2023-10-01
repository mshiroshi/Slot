struct Utility {
    static func randomReelNumber() -> Int {
        return symbols.randomElement()!
    }
    
    static func randomReelNumber(withoutNum: Int) -> Int {
        var array = symbols
        array.removeAll(where: {$0 == withoutNum })
        return array.randomElement()!
    }
    
    static func randomReelNumber(withoutNum1: Int, withoutNum2: Int) -> Int {
        var array = symbols
        array.removeAll(where: {$0 == withoutNum1 || $0 == withoutNum2 })
        return array.randomElement()!
    }
    
    static func randomNumber100() -> Int {
        return randomNumber(maxNum: 100)
    }
    
    static func randomNumber(maxNum: Int) -> Int {
        return Int.random(in: 1...maxNum)
    }
}
