import SwiftUI

struct GameCoverView: View {
    let game: Game
    
    var body: some View {
        ZStack {
            // 卡片背景图
            if let image = AppConfigs.loadImage(name: game.cardBackground) {
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
            }
                
            
                
            // 锁定状态显示锁图标
            if !game.isEnabled {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)

                    if let lockImage = AppConfigs.loadImage(name: "lock.png") {
                        Image(uiImage: lockImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                }
                
            } else {
                // 半透明覆盖层，确保文字清晰可见
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.1))
                    .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
            }
        }
    }
}
