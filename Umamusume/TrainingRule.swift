struct TrainingRule {
    private static let rules: [Rule] = [
        woodChip1, woodChip2, woodChip3,
        gate1, gate2, gate3,
        gate4, gate5, gate6,
        upSlope2
    ]
    
//    private static let rules: [Rule] = [
//        free, free, free,
//        free, free, free,
//        free, free, free,
//        free
//    ]
    
    private static let free = Rule(
        title: "フリー",
        message: "何でも成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return true
        })
    
    private static let woodChip1 = Rule(
        title: "ウッドチップ・軽め",
        message: "いずれか4つのトレーニングで30〜40で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isInnerRange(min: 30, max: 40, point1, point2, point3, point4, point5)
        })
    
    private static let woodChip2 = Rule(
        title: "ウッドチップ・普通",
        message: "いずれか4つのトレーニングで60〜70で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isInnerRange(min: 60, max: 70, point1, point2, point3, point4, point5)
        })
    
    private static let woodChip3 = Rule(
        title: "ウッドチップ・強め",
        message: "いずれか4つのトレーニングで70〜80で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isInnerRange(min: 70, max: 80, point1, point2, point3, point4, point5)
        })
    
    private static let upSlope1 = Rule(
        title: "坂路(上り)・弱め",
        message: "1〜40の範囲の中で\nスピード < スタミナ < パワー < 根性 < 賢さ で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isUp(min: 1, max: 40, point1, point2, point3, point4, point5)
        })
    
    private static let upSlope2 = Rule(
        title: "坂路(上り)・普通",
        message: "30〜70の範囲の中で\nスピード < スタミナ < パワー < 根性 < 賢さ で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isUp(min: 30, max: 70, point1, point2, point3, point4, point5)
        })
    
    private static let upSlope3 = Rule(
        title: "坂路(上り)・強め",
        message: "50〜90の範囲の中で\nスピード < スタミナ < パワー < 根性 < 賢さ で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isUp(min: 50, max: 90, point1, point2, point3, point4, point5)
        })
    
    private static let downSlope1 = Rule(
        title: "坂路(下り)・弱め",
        message: "40〜1の範囲の中で\nスピード > スタミナ > パワー > 根性 > 賢さ で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isDown(min: 1, max: 40, point1, point2, point3, point4, point5)
        })
    
    private static let downSlope2 = Rule(
        title: "坂路(下り)・強め",
        message: "70〜30の範囲の中で\nスピード > スタミナ > パワー > 根性 > 賢さ で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isDown(min: 30, max: 70, point1, point2, point3, point4, point5)
        })
    
    private static let downSlope3 = Rule(
        title: "坂路(下り)・強め",
        message: "90〜50の範囲の中で\nスピード > スタミナ > パワー > 根性 > 賢さ で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isDown(min: 50, max: 90, point1, point2, point3, point4, point5)
        })
    
    private static let gate1 = Rule(
        title: "ゲート練習",
        message: "いずれか1つが40のプラス・マイナス1の範囲で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isEqual(num: 40, point1, point2, point3, point4, point5)
        })
    
    private static let gate2 = Rule(
        title: "ゲート練習",
        message: "いずれか1つが50のプラス・マイナス1の範囲で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isEqual(num: 50, point1, point2, point3, point4, point5)
        })
    
    private static let gate3 = Rule(
        title: "ゲート練習",
        message: "いずれか1つが60のプラス・マイナス1の範囲で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isEqual(num: 60, point1, point2, point3, point4, point5)
        })
    
    private static let gate4 = Rule(
        title: "ゲート練習",
        message: "いずれか1つが70のプラス・マイナス1の範囲で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isEqual(num: 70, point1, point2, point3, point4, point5)
        })
    
    private static let gate5 = Rule(
        title: "ゲート練習",
        message: "いずれか1つが80のプラス・マイナス1の範囲で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isEqual(num: 80, point1, point2, point3, point4, point5)
        })
    
    private static let gate6 = Rule(
        title: "ゲート練習",
        message: "いずれか1つが90のプラス・マイナス1の範囲で成功",
        isValid: { (point1,point2,point3,point4,point5) in
            return isEqual(num: 90, point1, point2, point3, point4, point5)
        })
    
    static func getRuleIdList() -> [Int] {
        var ruleIdList: [Int] = []
        for id in 1...rules.count {
            ruleIdList.append(id)
        }
        return ruleIdList
    }
    
    static func get(ruleId: Int) -> Rule {
        return rules[ruleId - 1]
    }
    
    private static func isInnerRange(min: Int, max: Int, _ point1: Int?, _ point2: Int?, _ point3: Int?, _ point4: Int?, _ point5: Int?) -> Bool? {
        var successCount = 0
        
        if let p1 = point1 {
            if p1 >= min && p1 <= max {
                successCount += 1
            }
        }
        if let p2 = point2 {
            if p2 >= min && p2 <= max {
                successCount += 1
            }
        }
        if let p3 = point3 {
            if p3 >= min && p3 <= max {
                successCount += 1
            }
        }
        if let p4 = point4 {
            if p4 >= min && p4 <= max {
                successCount += 1
            }
        }
        if let p5 = point5 {
            if p5 >= min && p5 <= max {
                successCount += 1
            }
        }
        
        if point1 != nil && point2 != nil && point3 != nil && point4 != nil && point5 != nil {
            // OKが4つ以上なら成功
            if successCount >= 4 {
                return true
            } else {
                return false
            }
        } else if point1 != nil && point2 != nil && point3 != nil && point4 != nil {
            // OKが4つなら成功
            if successCount == 4 {
                return true
            }
            // OKが2つ以下なら失敗
            if successCount <= 2 {
                return false
            }
        } else if point1 != nil && point2 != nil && point3 != nil {
            // OKが1つ以下なら失敗
            if successCount <= 1 {
                return false
            }
        }
        else if point1 != nil && point2 != nil {
            // OKが無ければ失敗
            if successCount == 0 {
                return false
            }
        }
        
        return nil
    }
    
    private static func isUp(min: Int, max: Int, _ point1: Int?, _ point2: Int?, _ point3: Int?, _ point4: Int?, _ point5: Int?) -> Bool? {
        if let p1 = point1 {
            if p1 < min || p1 > max {
                return false
            }
        }
        if let p2 = point2 {
            if p2 < min || p2 > max {
                return false
            }
        }
        if let p3 = point3 {
            if p3 < min || p3 > max {
                return false
            }
        }
        if let p4 = point4 {
            if p4 < min || p4 > max {
                return false
            }
        }
        if let p5 = point5 {
            if p5 < min || p5 > max {
                return false
            }
        }

        if let p1 = point1, let p2 = point2, let p3 = point3, let p4 = point4, let p5 = point5 {
            if p1 < p2 && p2 < p3 && p3 < p4 && p4 < p5 {
                return true
            } else {
                return false
            }
        }
        
        return nil
    }
    
    private static func isDown(min: Int, max: Int, _ point1: Int?, _ point2: Int?, _ point3: Int?, _ point4: Int?, _ point5: Int?) -> Bool? {
        if let p1 = point1 {
            if p1 < min || p1 > max {
                return false
            }
        }
        if let p2 = point2 {
            if p2 < min || p2 > max {
                return false
            }
        }
        if let p3 = point3 {
            if p3 < min || p3 > max {
                return false
            }
        }
        if let p4 = point4 {
            if p4 < min || p4 > max {
                return false
            }
        }
        if let p5 = point5 {
            if p5 < min || p5 > max {
                return false
            }
        }
        
        if let p1 = point1, let p2 = point2, let p3 = point3, let p4 = point4, let p5 = point5 {
            if p1 > p2 && p2 > p3 && p3 > p4 && p4 > p5 {
                return true
            } else {
                return false
            }
        }
        
        return nil
    }
    
    private static func isEqual(num: Int, _ point1: Int?, _ point2: Int?, _ point3: Int?, _ point4: Int?, _ point5: Int?) -> Bool? {
        if let p1 = point1, p1 >= num - 1, p1 <= num + 1 {
            return true
        }
        if let p2 = point2, p2 >= num - 1, p2 <= num + 1 {
            return true
        }
        if let p3 = point3, p3 >= num - 1, p3 <= num + 1 {
            return true
        }
        if let p4 = point4, p4 >= num - 1, p4 <= num + 1 {
            return true
        }
        if let p5 = point5, p5 >= num - 1, p5 <= num + 1 {
            return true
        }
        
        if point1 != nil && point2 != nil && point3 != nil && point4 != nil && point5 != nil {
            return false
        }
        
        return nil
    }
}

class Rule {
    let title: String
    let message: String
    let isValid: (_ point1: Int?, _ point2: Int?, _ point3: Int?, _ point4: Int?, _ point5: Int?) -> Bool?
    
    init(title: String, message: String, isValid: @escaping (_ point1: Int?, _ point2: Int?, _ point3: Int?, _ point4: Int?, _ point5: Int?) -> Bool?) {
        self.title = title
        self.message = message
        self.isValid = isValid
    }
}
