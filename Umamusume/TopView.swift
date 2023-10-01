import SwiftUI

struct TopView: View {
    var body: some View {
        HStack {
            Image("top_logo")
                .resizable()
                .scaledToFit()
        }
        .frame(width: UIScreen.main.bounds.width, height: 50)
        .background(Color.white)
        .padding(.top, 20)
    }
}
