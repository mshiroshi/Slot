import SwiftUI

struct ReserveView: View {
    // 保留玉
    @StateObject var reserve: Reserve
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(reserve.units, id: \.self) { unit in
                Image(unit.type.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .animation(.default)
                    .transition(.opacity)
            }
        }
        .frame(height: 25)
        .padding(.top, 5)
    }
}

class Reserve: ObservableObject {
    @Published var units: [ReserveUnit] = []
    
    init() {
        // TODO
//        units.append(ReserveUnit(type: .silver))
//        units.append(ReserveUnit(type: .silver))
//        units.append(ReserveUnit(type: .gold))
//        units.append(ReserveUnit(type: .silver))
//        units.append(ReserveUnit(type: .silver))
//        units.append(ReserveUnit(type: .gold))
//        units.append(ReserveUnit(type: .silver))
//        units.append(ReserveUnit(type: .silver))
//        units.append(ReserveUnit(type: .gold))
    }
    
    func add() {
        let num = Utility.randomNumber100()
        
        withAnimation {
            if num >= 1 && num < 20 {
                units.append(ReserveUnit(type: .gold))
            } else {
                units.append(ReserveUnit(type: .silver))
            }
        }
    }
    
    func remove() {
        withAnimation {
            units.removeFirst()
        }
    }
}

struct ReserveUnit: Hashable {
    let id = UUID()
    let type: ReserveType
    let createDateTime = Date()
    
    init(type: ReserveType) {
        self.type = type
    }
    
    // Hashableプロトコルに必要なhashValueを実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Hashableプロトコルに必要な==演算子を実装
    static func == (lhs: ReserveUnit, rhs: ReserveUnit) -> Bool {
        lhs.id == rhs.id
    }
}

enum ReserveType: String {
    case gold = "reserve_gold"
    case silver = "reserve_silver"
}
