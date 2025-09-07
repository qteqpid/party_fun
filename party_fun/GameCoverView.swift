import SwiftUI

// 游戏封面视图
struct GameCoverView: View {
    let game: Game
    // 控制游戏规则弹窗的显示状态
    @State private var isShowingRules = false
    // 控制锁定提示弹窗的显示状态
    @State private var isShowingLockAlert = false
    
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
                            .shadow(color: .yellow, radius: 5, x: 0, y: 0)
                            // 添加点击手势显示锁定提示
                            .onTapGesture {
                                isShowingLockAlert.toggle()
                            }
                    }
                }
                
            } else {
                // 下半部分半透明蒙层和游戏规则文字
                VStack {
                    Spacer()
                    // 半透明蒙层
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight * 0.2)
                        // 添加点击手势
                        .onTapGesture {
                            isShowingRules.toggle()
                        }
                        .overlay(alignment: .center) {
                            // 游戏规则文字
                            Text("游戏规则")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .shadow(radius: 2)
                        }
                }
            }
        }
        // 游戏规则弹窗 - 设置为半屏sheet
        .sheet(isPresented: $isShowingRules) {
            GameRulePopupView(isShowing: $isShowingRules, gameName: game.gameName)
                // 设置为半屏显示
                .presentationDetents([.medium])
                // 显示拖动指示器
                .presentationDragIndicator(.visible)
        }
        // 锁定提示弹窗 - 美化的alert
        .alert("啥时候能玩？", isPresented: $isShowingLockAlert) {
            Button("行，再给你几天时间") {}
                .foregroundColor(Color.white)
        } message: {
            Text("别问，问就是马上就弄好了")
                .font(.body)
                .foregroundColor(Color.primary)
        }
    }
}
