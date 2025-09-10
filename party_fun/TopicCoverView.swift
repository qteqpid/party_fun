import SwiftUI

// 主题封面视图组件
struct TopicCoverView: View {
    let topic: Topic
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // 卡片背景图 - 使用与游戏封面类似的样式
            if let image = AppConfigs.loadImage(name: topic.topicImage) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    // 添加立体感的金色描边效果
                    .overlay(
                        ZStack {
                            // 内层金色描边（主色）
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow, lineWidth: 0.3)
                        }
                    )
                    .shadow(radius: 10)
                    .onTapGesture {
                        onTap()
                    }
            }
            
            // 半透明蒙层和主题名称
            VStack {
                Spacer()
                // 半透明蒙层
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
                    .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight * 0.2)
                    .overlay(alignment: .center) {
                        // 主题名称文字
                        Text(topic.topicName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .shadow(radius: 2)
                    }
            }
        }
    }
}
