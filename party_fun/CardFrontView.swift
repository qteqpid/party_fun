import SwiftUI

struct CardFrontView: View {
    var currentImagePair: (background: UIImage?, foreground: Color)
    var card: Card?
    var rotationY: Double

    // 计算卡片是否应该显示（根据旋转角度）
    private var isVisible: Bool {
        let angle = rotationY.truncatingRemainder(dividingBy: 360)
        return angle >= 90 && angle <= 270
    }

    var body: some View {
        ZStack {
            // 内容容器，设置最大宽度和内边距
            VStack {
                // card.title
                if let card = card, let _ = card.title {
                    LineView(
                        line: card.title!,
                        foregroundColor: currentImagePair.foreground,
                        width: AppConfigs.cardWidth - 40
                    )
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                }
                Spacer()
                // card.body
                if let card = card, let _ = card.body {
                    MultiLineView(
                        lines: card.body!,
                        foregroundColor: currentImagePair.foreground,
                        width: AppConfigs.cardWidth - 40,
                    ).border(Color.red)
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                }
                Spacer()
                // card.body2
                if let card = card, let _ = card.body2 {
                    MultiLineView(
                        lines: card.body2!,
                        foregroundColor: currentImagePair.foreground,
                        width: AppConfigs.cardWidth - 40,
                    ).border(Color.red)
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                }
            }
            .padding(20) // 添加内边距
            .frame(maxWidth: AppConfigs.cardWidth, maxHeight: AppConfigs.cardHeight)
            
            // Smile图片放置在右上角
            if let smile = AppConfigs.loadImage(name: "face.png") {
                Image(uiImage: smile)
                    .renderingMode(.template) // 设置为模板模式，使foregroundColor生效
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .position(x: AppConfigs.cardWidth, y: 60) // 右上角位置，考虑圆角和内边距
                    .foregroundColor(currentImagePair.foreground)
            }
            
        }
        .background {
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

            } else {
                // 使用颜色背景（保持原有逻辑）
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(radius: 15)
                    .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))
    }
}
