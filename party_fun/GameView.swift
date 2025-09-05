//
//  GameView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI


// 游戏视图
struct GameView: View {
    let game: Game
    
    @State private var isFlipping = false
    @State private var card: Card? = nil
    @State private var rotationY = 0.0
    @State private var currentColorPair = (background: Color.white, foreground: Color.black)
    
    var body: some View {
        ZStack {
            // 背景色
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // 标题栏
                HStack {
                    Spacer()
                    Text(game.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .padding()
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
                        .frame(width: 300, height: 400)
                        .opacity(rotationY.truncatingRemainder(dividingBy: 360) < 90 || rotationY.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)
                        .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                    
                    // 背面图片
                    if let image = AppConfigs.loadImage(imageName: game.cardBackground, imageType: "png") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 280, height: 380)
                            .clipped()
                            .cornerRadius(15)
                            .opacity(rotationY.truncatingRemainder(dividingBy: 360) < 90 || rotationY.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)
                            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                    }
                    
                    // 使用独立的CardChatView组件显示卡片正面
                    CardChatView(
                        currentColorPair: currentColorPair,
                        card: card,
                        rotationY: rotationY
                    )
                }
                
                Spacer()
                
                // 圆形大按钮 - 点击开始翻牌，再次点击停止翻牌
                Button(action: {
                    // 切换翻牌状态
                    if isFlipping {
                        stopFlipping()
                    } else {
                        startFlipping()
                    }
                }) {
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
                    
                    // 随机选择一个颜色对
                    if let colorPair = AppConfigs.colorPairs.randomElement() {
                        currentColorPair = (
                            background: Color(hex: colorPair.0) ?? Color.white,
                            foreground: Color(hex: colorPair.1) ?? Color.black
                        )
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
