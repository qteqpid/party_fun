import SwiftUI
/**
支持 title + subtitle,  或者 title + answer这样的组合
*/
struct CardCommonView: View {
    var currentImagePair: (background: UIImage?, foreground: Color)
    var card: Card?
    var rotationY: Double
    var contentWidth: CGFloat
    var isTitleSingleLine: Bool
    @State private var isShowingAnswer = false

    // 计算卡片是否应该显示（根据旋转角度）
    private var isVisible: Bool {
        let angle = rotationY.truncatingRemainder(dividingBy: 360)
        return angle >= 90 && angle <= 270
    }

    var body: some View {
        ZStack {
            // 内容容器，设置最大宽度和内边距
            VStack {
                Spacer()
                if let card = card, let _ = card.title {
                    LineView(
                        line: card.title!,
                        foregroundColor: currentImagePair.foreground,
                        width: contentWidth,
                        alignment: .center,
                        isSingleLine: isTitleSingleLine
                    )
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                }
                Spacer().frame(height: AppConfigs.cardHeight * 0.1)
                // subtitle
                if let card = card, let _ = card.subtitle {
                    LineView(
                        line: card.subtitle!,
                        foregroundColor: currentImagePair.foreground,
                        width: contentWidth,
                        alignment: .center,
                        isSingleLine: false
                    )
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                }
                // answer
                if let card = card, let _ = card.answer {
                    AnswerView(
                        line: card.answer!,
                        foregroundColor: currentImagePair.foreground,
                        width: contentWidth,
                        alignment: .center,
                        isShowingAnswer: $isShowingAnswer
                    )
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                }
                Spacer()
            }
            .padding(20) // 添加内边距
            .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
            // 当卡片变化时重置答案显示状态
            .onChange(of: card) {
                isShowingAnswer = false
            }
        }
        .background {
            // 卡片正面背景 - 支持图片或颜色
            if let cardForeground = currentImagePair.background {
                // 使用图片背景
                Image(uiImage: cardForeground)
                    .resizable()
                    .scaledToFit()
                    .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
                    .cornerRadius(25)
                    .shadow(radius: 15)
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
