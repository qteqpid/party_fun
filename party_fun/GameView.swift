//
//  GameView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI


// 优化的背景图片视图，独立于前景动画
struct BackgroundImageView: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .overlay(Color.black.opacity(0.2)) // 添加半透明遮罩增强可读性
            .accessibility(hidden: true) // 对辅助功能隐藏
            .drawingGroup() // 优化渲染性能
    }
}

// 游戏视图
struct GameView: View {
    let game: Game
    
    @State private var isFlipping = false
    @State private var card: Card? = nil
    @State private var rotationY = 0.0
    @State private var currentImagePair = (background: Game.defaultImagePairs.first?.0, foreground: Color.white)
    @State private var currentImageIndex = 0 // 添加索引变量用于循环选择图片
    
    // 预加载背景图片以提高性能
    private let bgImage: UIImage? = AppConfigs.loadImage(name: AppConfigs.bgImage)
    
    var body: some View {
        ZStack {
            // 优化背景图片渲染 - 使用单独的图层并设置为固定背景
            if let bgImage = bgImage {
                // 使用单独的视图作为背景，避免与前景动画交互
                BackgroundImageView(image: bgImage)
                    .ignoresSafeArea()
            } else {
                // 回退渐变色背景
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
            
            VStack {
                // 标题栏
                HStack {
                    Spacer()
                    Text(game.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 40)
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // 大卡片 - 正反面设计
                ZStack {
                    // 卡片背面 - 显示游戏图片
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .shadow(radius: 15)
                        .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
                        .opacity(rotationY.truncatingRemainder(dividingBy: 360) < 90 || rotationY.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)
                        .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                    
                    // 背面图片
                    if let image = AppConfigs.loadImage(name: game.cardBackground) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: AppConfigs.cardWidth - 20, height: AppConfigs.cardHeight - 20)
                            .clipped()
                            .cornerRadius(15)
                            .opacity(rotationY.truncatingRemainder(dividingBy: 360) < 90 || rotationY.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)
                            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                    }
                    
                    // 使用独立的CardChatView组件显示卡片正面
                    CardChatView(
                        currentImagePair: currentImagePair,
                        card: card,
                        rotationY: rotationY
                    )
                }
                
                Spacer().frame(height: 40)
                
                // 圆形大按钮 - 点击开始翻牌，再次点击停止翻牌
                Button {
                    // 切换翻牌状态
                    if isFlipping {
                        stopFlipping()
                    } else {
                        startFlipping()
                    }
                } label: {
                    if let buttonImg = AppConfigs.loadImage(name: "button.png") {
                        Image(uiImage: buttonImg)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .overlay(
                                Text(isFlipping ? "STOP" : "START")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(isFlipping ? Color(hex: "#831c21") : Color.white)
                                    .shadow(radius: 2)
                                )
                            .scaleEffect(isFlipping ? 0.9 : 1.0)
                            .opacity(isFlipping ? 0.9 : 1.0)
                            .shadow(radius: isFlipping ? 8 : 5)
                            .animation(.easeInOut(duration: 0.3), value: isFlipping)
                    } else {
                        Circle()
                        .fill(isFlipping ? Color.red : Color.blue)
                        .scaleEffect(isFlipping ? 0.9 : 1.0)
                        .frame(width: 150, height: 150)
                        .shadow(radius: isFlipping ? 15 : 10)
                        .overlay(
                            Text(isFlipping ? "停止翻牌" : "开始翻牌")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                        )
                        .animation(.easeInOut, value: isFlipping)
                    } 
                }
                
                Spacer()
            }
        }
    }
    
    // 开始翻转卡片
    private func startFlipping() {
        isFlipping = true
        
        // 设置定时翻转效果
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if isFlipping {
                // 翻转到180度
                withAnimation(.easeInOut(duration: 0.3)) {
                    rotationY += 180
                }
                
                // 延迟更新内容，确保在翻转过程中更新
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    card = game.cards.randomElement()
                    // 循环选择下一个图片对
                    if !game.imagePairs().isEmpty {
                        currentImagePair = game.imagePairs()[currentImageIndex]
                        // 递增索引并循环回绕
                        currentImageIndex = (currentImageIndex + 1) % game.imagePairs().count
                    }
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    // 停止翻转卡片
    private func stopFlipping() {
        isFlipping = false
        
        // 确保卡片最终停在正面（有字的一面）
        // 计算当前角度模360
        let currentAngle = rotationY.truncatingRemainder(dividingBy: 360)
        
        // 如果当前不是正面朝上，翻转到下一个正面位置
        if !(currentAngle >= 90 && currentAngle <= 270) {
            withAnimation(.easeInOut(duration: 0.3)) {
                // 如果当前在0-90度之间，需要再转180度
                // 如果当前在270-360度之间，需要再转180度
                rotationY += 180
            }
        }
    }
}
