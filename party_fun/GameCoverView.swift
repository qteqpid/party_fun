import SwiftUI

struct GameCoverView: View {
    let game: Game
    
    var body: some View {
        ZStack {
            // 卡片背景图
            if let image = AppConfigs.loadImage(imageName: game.cardBackground, imageType: "png") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
            }
                
            
                
            // 锁定状态显示锁图标
            if !game.isEnabled {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 150, height: 200)

                    if let lockImage = AppConfigs.loadImage(imageName: "lock", imageType: "png") {
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
                    .frame(width: 150, height: 200)
            }
        }
    }
}
