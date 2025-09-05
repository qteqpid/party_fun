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
                // 更喜庆的背景色
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    // 标题层 - 严格居中
                    Text("聚会卡牌游戏")
                        .font(.system(size: 30, weight: .black, design: .rounded))
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
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(AppConfigs.games) { game in
                                // 使用GameCoverView组件显示卡片
                                if game.isEnabled {
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
    }
}



#Preview {
    ContentView()
}
