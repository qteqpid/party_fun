import SwiftUI

struct CardHaiguiView: View {
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
                Spacer()
                // card.title
                if let card = card, let _ = card.title {
                    LineView(
                        line: card.title!,
                        foregroundColor: currentImagePair.foreground,
                        width: AppConfigs.cardWidth * 0.6,
                        alignment: .center
                    )
                    .shadow(color: Color.gray.opacity(0.7), radius: 1, x: 1, y: 1) // 阴影增强立体感
                }
                // card.image
                if let card = card, let _ = card.image {
                    if let qr_img = AppConfigs.loadImage(name: card.image) {
                    Image(uiImage: qr_img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: AppConfigs.cardWidth * 0.15, height: AppConfigs.cardWidth * 0.15)
                        .shadow(radius: 15)
                        .onLongPressGesture {
                            // 长按打开App Store页面
                            // 使用itms-apps协议直接打开应用商店
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id6749227316") {
                                UIApplication.shared.open(url)
                            }
                        }
                }
                }
            }
            .padding(20) // 添加内边距
            .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
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
                    .fill(Color.black)
                    .shadow(radius: 15)
                    .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .rotation3DEffect(.degrees(rotationY + 180), axis: (x: 0, y: 1, z: 0))
    }
}
