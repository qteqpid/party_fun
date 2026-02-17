//
//  GameView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI
import UIKit
import StoreKit




// 游戏视图
struct GameView: View {
    let game: Game
    @Binding var showPurchaseView: Bool    
    @State private var isFlipping = false
    @State private var card: Card? = nil
    @State private var rotationY = 0.0
    @State private var currentImagePair = (background: Game.defaultImagePairs.first?.0, foreground: Color.white)
    @State private var currentImageIndex = 0 // 添加索引变量用于循环选择图片
    @State private var showRatingAlert = false // 控制是否显示评分弹窗
    
    // 新添加的状态变量
    @State private var showTopicSetting = false // 控制是否显示主题游戏设置弹窗
    @State private var selectedTopic: Topic? = nil // 存储当前选择的主题
    @State private var selectedDuration: Int = 180 // 存储选择的游戏时长，默认180秒（3分钟）
    @State private var showLandscapeView = false // 控制是否显示横屏视图
    
    // 预加载背景图片以提高性能
    private let bgImage: UIImage? = AppConfigs.loadImage(name: AppConfigs.bgImage)
    
    var body: some View {
        ZStack{
            VStack {
                // 标题栏
                HStack {
                    Spacer()
                    Text(game.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 10)
                    Spacer()
                }
                .padding()

                // 根据游戏类型选择不同的视图组件
                if game.gameName == .wodi {
                    Spacer()
                    WodiGameView(game: game, showPurchaseView: $showPurchaseView)
                } else if let topics = game.topics {
                    GridCardView(
                            game: game,
                            topics: topics,
                            onTopicSelect: {
                                selectedTopic in
                                // 显示主题游戏设置弹窗，添加动画效果
                                InAppPurchaseManager.shared.increaseUseTimes()
                                if InAppPurchaseManager.shared.shouldShowPurchaseAlert() {
                                    showPurchaseView = true
                                } else {
                                    self.selectedTopic = selectedTopic
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.showTopicSetting = true
                                    }
                                }
                                
                            }
                        )
                } else {
                    Spacer()
                    SingleCardView(
                        game: game,
                        card: card,
                        rotationY: rotationY,
                        currentImagePair: currentImagePair,
                        isFlipping: isFlipping,
                        onButtonTap: {
                            InAppPurchaseManager.shared.increaseUseTimes()
                            if InAppPurchaseManager.shared.shouldShowPurchaseAlert() {
                                showPurchaseView = true
                            } else {
                                // 处理按钮点击事件
                                if isFlipping {
                                    stopFlipping()
                                } else {
                                    startFlipping()
                                }
                            }
                            
                            
                        }
                    )
                }
                
                Spacer()
            }
            .background {
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
            }
            .ratingAlert(isPresented: $showRatingAlert)
            
            // 条件显示主题游戏设置弹窗
            if showTopicSetting, let topic = selectedTopic {
                TopicGameSettingView(
                    topic: topic,
                    onStartGame: { duration in
                        // 开始游戏并显示横屏视图
                        startGameWithTopicAndDuration(topic, duration: duration)
                    },
                    onDismiss: {
                        showTopicSetting = false
                    }
                )
            }
            
            // 条件显示横屏视图
            if showLandscapeView, let topic = selectedTopic {
                // 找到该主题类型对应的卡片
                let topicCards = game.cards.filter { $0.topicType == topic.topicType }
                
                // 使用用户选择的游戏时长
                LandscapeGameView(
                    topicCards: topicCards,
                    duration: selectedDuration,
                    onBack: {
                        showLandscapeView = false
                    }
                )
            }
        }.onAppear {
            InAppPurchaseManager.shared.increaseUseTimes()
            AppRatingManager.shared.incrementButtonTapCount()
            if InAppPurchaseManager.shared.shouldShowPurchaseAlert() {
                showPurchaseView = true
            } else {
                if AppRatingManager.shared.shouldShowRatingAlert() {
                    showRatingAlert = true
                }
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
                    if (AppConfigs.isDebug) {
                        card = game.cards.first
                    } else {
                        card = game.cards.randomElement()
                    }
                    
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
    
    
    // 开始特定主题和时长的游戏，并切换到横屏视图
    private func startGameWithTopicAndDuration(_ topic: Topic, duration: Int) {
        // 存储选择的主题
        selectedTopic = topic
        // 存储选择的游戏时长
        selectedDuration = duration
        // 隐藏设置弹窗
        showTopicSetting = false
        // 显示横屏视图
        showLandscapeView = true
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


// 单卡片视图组件
struct SingleCardView: View {
    let game: Game
    let card: Card?
    let rotationY: Double
    let currentImagePair: (background: UIImage?, foreground: Color)
    let isFlipping: Bool
    let onButtonTap: () -> Void
    
    var body: some View {
        VStack {

            
            // 大卡片 - 正反面设计
            ZStack {
                // 卡片背面 - 显示游戏图片
                // 使用独立的CardBackView组件
                CardBackView(
                    game: game,
                    rotationY: rotationY
                )
                
                // 根据游戏名称显示不同的卡片正面视图
                if game.gameName == .chat {
                    CardChatView(
                        currentImagePair: currentImagePair,
                        card: card,
                        rotationY: rotationY
                    )
                } else if game.gameName == .haigui {
                    CardHaiguiView(
                        currentImagePair: currentImagePair,
                        card: card,
                        rotationY: rotationY
                    )
                } else if game.gameName == .truth {
                    CardCommonView(
                        currentImagePair: currentImagePair,
                        card: card,
                        rotationY: rotationY,
                        contentWidth: AppConfigs.cardWidth * 0.6,
                        isTitleSingleLine: true
                    )
                } else if game.gameName == .cut {
                    CardCommonView(
                        currentImagePair: currentImagePair,
                        card: card,
                        rotationY: rotationY,
                        contentWidth: AppConfigs.cardWidth * 0.8,
                        isTitleSingleLine: false
                    )
                } else if game.gameName == .emoji {
                    CardCommonView(
                        currentImagePair: currentImagePair,
                        card: card,
                        rotationY: rotationY,
                        contentWidth: AppConfigs.cardWidth * 0.8,
                        isTitleSingleLine: true
                    )
                } else if game.gameName == .trick {
                    CardCommonView(
                        currentImagePair: currentImagePair,
                        card: card,
                        rotationY: rotationY,
                        contentWidth: AppConfigs.cardWidth * 0.8,
                        isTitleSingleLine: false
                    )
                } else {
                    // TODO: 为其他游戏类型提供默认视图
                }
            }
            
            Spacer().frame(height: 40)
            
            // 圆形大按钮 - 点击开始翻牌，再次点击停止翻牌
            // 使用独立的ButtonView组件
            ButtonView(
                isActive: isFlipping,
                onButtonTap: onButtonTap
            )
        }
    }
}

// 网格卡片视图组件 - 用于guess游戏
struct GridCardView: View {
    let game: Game
    let topics: [Topic] 
    let onTopicSelect: (Topic) -> Void
    
    var body: some View {
        ScrollView {
            // 网格布局展示主题卡片
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(topics, id: \.id) { topic in
                    TopicCoverView(
                        topic: topic,
                        onTap: {
                            onTopicSelect(topic)
                        }
                    )
                }
            }
            .padding()
            
            Spacer()
        }
    }
}


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
