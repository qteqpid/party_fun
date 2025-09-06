//
//  ContentView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI
import UIKit



struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // 标题层 - 严格居中
                    Text("聚会卡牌游戏")
                        .font(.system(size: AppConfigs.appTitleSize, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.blue,
                                    Color.yellow,
                                    
                                    Color.cyan
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    
                    // 可无限下拉的ScrollView
                    ScrollView {
                        Spacer().frame(height: 20)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(AppConfigs.games) { game in
                                // 使用GameCoverView组件显示卡片
                                if game.isEnabled && game.cards.count > 0 {
                                    // 仅当游戏启用时才允许点击进入
                                    NavigationLink(destination: GameView(game: game)) {
                                        GameCoverView(game: game)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    // 游戏禁用时不添加导航链接
                                    GameCoverView(game: game)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        // 将背景作为修饰符添加，不影响前景布局
        .background {
            // 优先使用图片作为背景，不存在时回退到渐变色
            if let image = AppConfigs.loadImage(name: AppConfigs.bgImage) {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                    // // 添加半透明遮罩，提高前景内容可读性
                    // Color.black.opacity(0.3)
                    //     .ignoresSafeArea()
                }
            } else {
                // 更喜庆的背景色
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
        }
    }
}



#Preview {
    ContentView()
}
