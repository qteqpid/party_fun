//
//  ContentView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI
import UIKit


extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backBarButtonItem = 
        UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
    }
}
struct ContentView: View {
    @StateObject private var purchaseManager = InAppPurchaseManager.shared
    @State private var showRatingAlert = false // 控制是否显示评分弹窗
    @State private var showPurchaseView = false
    
    // init() {
    //     let appearance = UINavigationBarAppearance()
    //     appearance.backgroundColor = .clear
    //     appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    //     UINavigationBar.appearance().standardAppearance = appearance
    // }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // 标题层 - 严格居中
                    ZStack {
                        Text("嗨玩")
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
                        // TODO: 加一个设置入口，浮在标题右侧
                        HStack {
                            Spacer()
                            NavigationLink(destination: SettingsView(showPurchaseView: $showPurchaseView, backgroundColor: Color(hex: "#2d2d2d"))) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                    
                    
                    
                    // 可无限下拉的ScrollView
                    ScrollView {
                        Spacer().frame(height: 20)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(AppConfigs.games) { game in
                                // 使用GameCoverView组件显示卡片
                                if game.isEnabled {
                                    // 仅当游戏启用时才允许点击进入
                                    NavigationLink(destination: GameView(game: game, showPurchaseView: $showPurchaseView)) {
                                        GameCoverView(game: game)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
        .onAppear {
            // 在首页加载时检查是否应该显示评分弹窗
            if AppRatingManager.shared.shouldShowRatingAlert() {
                showRatingAlert = true
            }
        }
        .ratingAlert(isPresented: $showRatingAlert)
        .sheet(isPresented: $showPurchaseView) {
            PurchaseView(purchaseManager: purchaseManager, showRatingAlert: $showRatingAlert)
        }
    }
}



#Preview {
    ContentView()
}
