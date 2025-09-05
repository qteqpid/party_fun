import SwiftUI

struct CardChatView: View {
    var currentColorPair: (background: Color, foreground: Color)
    var card: Card?
    var rotationY: Double
    
    var body: some View {
        ZStack {
            // 卡片正面背景
            RoundedRectangle(cornerRadius: 25)
                .fill(currentColorPair.background)
                .shadow(radius: 15)
                .frame(width: 300, height: 400)
                .opacity(rotationY.truncatingRemainder(dividingBy: 360) >= 90 && rotationY.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))
            
            // 正面文字内容
            Text(card?.body ?? "暂无内容")
                .font(.title2)
                .foregroundColor(currentColorPair.foreground)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: 280, height: 380)
                .minimumScaleFactor(0.5)
                .lineLimit(nil)
                .opacity(rotationY.truncatingRemainder(dividingBy: 360) >= 90 && rotationY.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))
        }
    }
}