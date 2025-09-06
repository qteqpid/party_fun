import SwiftUI

struct CardChatView: View {
    var currentImagePair: (background: UIImage?, foreground: Color)
    var card: Card?
    var rotationY: Double

    var body: some View {
        ZStack {
            // 卡片正面背景 - 支持图片或颜色
            if let cardForeground = currentImagePair.background {
                // 使用图片背景
                Image(uiImage: cardForeground)
                    .resizable()
                    .scaledToFill()
                    .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
                    .cornerRadius(25)
                    .shadow(radius: 15)
                    .overlay(
                        ZStack {
                            // 内层金色描边（主色）
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.yellow, lineWidth: 0.5)
                        }
                    )
                    .opacity(rotationY.truncatingRemainder(dividingBy: 360) >= 90 && rotationY.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                    .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))

            } else {
                // 使用颜色背景（保持原有逻辑）
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(radius: 15)
                    .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
                    .opacity(rotationY.truncatingRemainder(dividingBy: 360) >= 90 && rotationY.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                    .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))
            }
            
            // card.splitBody
            if let card = card, let _ = card.splitBody {
                SplitBodyView(
                    card: card,
                    foregroundColor: currentImagePair.foreground,
                    width: AppConfigs.cardWidth - 20,
                    height: AppConfigs.cardHeight - 20
                )
                .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                .opacity(rotationY.truncatingRemainder(dividingBy: 360) >= 90 && rotationY.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))
            }
            // card.body
            if let card = card, let _ = card.body {
                Text(card.body ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(currentImagePair.foreground)
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: AppConfigs.cardWidth - 20, height: AppConfigs.cardHeight - 20)
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
                    .opacity(rotationY.truncatingRemainder(dividingBy: 360) >= 90 && rotationY.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                    .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))
            }
            
        }
    }
}
