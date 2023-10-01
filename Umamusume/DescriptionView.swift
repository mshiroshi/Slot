import SwiftUI

struct DescriptionView: View {
    @ObservedObject var gameState: GameState
    @State var isSlideAnimation = true
    
    var body: some View {
        ZStack {
            if isSlideAnimation {
                RoundedRectangle(cornerRadius: 80)
                    .fill(.white)
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 80)
                            .stroke(Color.green, lineWidth: 2)
                    )
                    .padding(EdgeInsets(
                        top: 20,
                        leading: 20,
                        bottom: 20,
                        trailing: 20
                    ))
                    .overlay(
                        Text(getMessage())
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: 50, y:0)
                    )
                    .overlay(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green)
                            .frame(width:150, height: 24)
                            .overlay(
                                Text(getTitle())
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .offset(x:20, y:10)
                    }
                    .offset(x:0, y:5)
                    .transition(.slide)
                    .onChange(of: gameState.turn) { turn in
                        // フェードアウト
                        withAnimation() {
                            isSlideAnimation = false
                        }
                        // フェードイン
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation() {
                                isSlideAnimation = true
                            }
                        }
                        
                    }
            }
        }
        .frame(height: 110)
    }
    
    private func getTitle() -> String {
        let rule = TrainingRule.get(ruleId: gameState.getCurrentRuleId())
        return rule.title
    }
    
    private func getMessage() -> String {
        let rule = TrainingRule.get(ruleId: gameState.getCurrentRuleId())
        return rule.message
    }
}
