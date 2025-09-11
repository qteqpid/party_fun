import SwiftUI
import SwiftUI
import UIKit
import CoreMotion

enum Direction {
    case screenUp
    case screenDown
    case screenFront
    case unknown
}

enum Stage {
    case beforeReady
    case isReady
    case gameStarted
    case gameEnded
}

struct LandscapeGameView: View {
    let topicCards: [Card]
    let duration: Int
    let onBack: () -> Void
    
    // 设备方向状态
    // Core Motion 管理器
    @State private var motionManager: CMMotionManager? = nil
    // 设备倾斜状态
    @State private var screenDirection: Direction? = .unknown
    
    // 倒计时状态
    @State private var readyCountdown: Int = 3
    @State private var gameCountdown: Int = 0
    @State private var readyTimer: Timer? = nil
    @State private var gameTimer: Timer? = nil
    
    // 游戏状态
    @State private var currentStage: Stage = .beforeReady
    @State private var currentCardIndex: Int = 0
    @State private var correctAnswers: Int = 0
    
    // 返回按钮显示状态
    @State private var backButtonOpacity: Double = 0
    @State private var backButtonTimer: Timer? = nil

    // 切换题目
    @State private var showSkip: Bool = false
    @State private var showCorrect: Bool = false
    
    var isLandscapeLeft: Bool {
        let result = screenDirection == .screenFront
        return result
    }
    
    // 将秒数转换为mm:ss格式
    var formattedGameCountdown: String { 
        let minutes = gameCountdown / 60
        let seconds = gameCountdown % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 获取当前卡片内容
    var currentCardContent: String {
        guard currentCardIndex < topicCards.count else {
            return "没有更多卡片了"
        }
        if showSkip {
            return "跳过"
        }
        if showCorrect {
            return "答对了"
        }
        let card = topicCards[currentCardIndex]
        // 获取卡片的主要内容
        if let title = card.title {
            return title.line.map { $0.content }.joined()
        }
        return ""
    }

    // 获取当前卡片背景色
    var currentCardBackgroundColor: Color {
        if showSkip {
            return Color.red
        }
        if showCorrect {
            return Color.green
        }
        return Color.blue
    }
    
    // 启动加速计更新
    private func startAccelerometerUpdates() {
        if let motionManager = motionManager, motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2 // 更新频率0.2
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let accelerometerData = data, error == nil else {
                    print("no data or has error")
                    return
                }
                let x = accelerometerData.acceleration.x
                let y = accelerometerData.acceleration.y
                let z = accelerometerData.acceleration.z
                
                if (screenDirection != .screenFront && (
                    x < -0.5 && abs(y) < 0.3 && abs(z) < 0.3
                )) {
                    print("屏幕向前")
                    screenDirection = .screenFront
                    if (currentStage == .beforeReady) {
                        startReadyCountdown()
                    } else if currentStage == .gameStarted {
                        //切到下一题
                        if (showSkip || showCorrect) {
                            // 切换到下一题
                            showSkip = false
                            showCorrect = false
                            currentCardIndex += 1
                            if currentCardIndex >= topicCards.count {
                                endGame(playVoice: true)
                            } else {
                                MusicPlayer.shared.playAudio(named: "flip_paper.m4a")
                            }
                        }
                    }
                }

                if (screenDirection != .screenUp && (
                    z < -0.4 && abs(x) < 0.6 && abs(y) < 0.5
                )) {
                    print("屏幕向上")
                    screenDirection = .screenUp
                    handleScreenRotation()
                }
                
                if (screenDirection != .screenDown && (
                    z > 0.4 && abs(x) < 0.6 && abs(y) < 0.5
                )) {
                    print("屏幕向下")
                    screenDirection = .screenDown
                    handleScreenRotation()
                }


                // 当设备处于横屏模式时，检测上仰/下翻状态
                // print("x: \(accelerometerData.acceleration.x)")
                // print("y: \(accelerometerData.acceleration.y)")
                // print("z: \(accelerometerData.acceleration.z)")
                // print("=========")
                
            }
        }
    }
    
    // 请求Core Motion权限
    private func requestMotionPermission() {
        let activityManager = CMMotionActivityManager()
        
        // 在iOS中，没有直接的API来请求Core Motion权限
        // 通常是通过尝试使用相关功能来触发系统权限提示
        activityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
            // 立即停止活动更新，我们只是为了触发权限请求
            activityManager.stopActivityUpdates()
            
            // 检查权限状态是否已变为授权
            let authorizationStatus = CMMotionActivityManager.authorizationStatus()
            if authorizationStatus == .authorized {
                print("Core Motion权限已授权")
                self.startAccelerometerUpdates()
            } else {
                print("Core Motion权限未授权")
            }
        }
    }
    
    var body: some View {
        // 在竖屏模式下模拟横屏显示
        GeometryReader {
            geometry in
            
            // 获取屏幕尺寸
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // 计算在竖屏模式下模拟横屏的合适尺寸
            let contentWidth = screenHeight * 0.9 // 使用屏幕高度的90%作为内容宽度
            let contentHeight = screenWidth * 0.8 // 使用屏幕宽度的80%作为内容高度
            
            // 计算内容居中位置
            let centerX = screenWidth / 2
            let centerY = screenHeight / 2
            
            ZStack {
                // 背景色
                currentCardBackgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    // 返回按钮，默认隐藏，点击屏幕时显示
                    Button(action: {
                        endGame(playVoice: false)
                        onBack()
                    }) {
                        Image(systemName: "chevron.up.circle")
                            .font(.system(size: 30 * AppConfigs.cardFrontFontSizeScale))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .opacity(backButtonOpacity)
                    .onTapGesture {
                        // 确保按钮自身点击事件不影响主视图的点击事件
                        endGame(playVoice: false)
                        onBack()
                    }
                    Spacer()
                }


                // 旋转内容，在竖屏模式下模拟横屏效果
                ZStack {
                    VStack {
                        if currentStage == .beforeReady {
                            Spacer()
                            // 初始状态
                            Text(AppConfigs.isIphone ? "请把屏幕横屏面向队友" : "此游戏仅支持在苹果手机上玩")
                                .font(.system(size:100 * AppConfigs.cardFrontFontSizeScale))
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .padding()
                            Spacer()
                        } else if currentStage == .isReady {
                            Spacer()
                            // 显示准备开始倒计时
                            Text("准备开始")
                                .font(.system(size:80 * AppConfigs.cardFrontFontSizeScale))
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                 
                            // 显示倒计时
                            if readyCountdown > 0 {
                                Text("\(readyCountdown)")
                                    .font(.system(size: 100 * AppConfigs.cardFrontFontSizeScale))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding()
                            }
                            Spacer()
                        } else if currentStage == .gameStarted {
                            // 游戏进行中
                            VStack {
                                // 显示游戏倒计时
                                Text(formattedGameCountdown)
                                    .font(.system(size:40 * AppConfigs.cardFrontFontSizeScale))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)                               
                                Spacer()
                                // 显示当前卡片内容
                                Text(currentCardContent)
                                    .font(.system(size:140 * AppConfigs.cardFrontFontSizeScale))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .padding()
                                Spacer()
                            }
                        } else if currentStage == .gameEnded {
                            Spacer()
                            // 游戏结束，显示结果
                            VStack {
                                Text("游戏结束")
                                    .font(.system(size: 40 * AppConfigs.cardFrontFontSizeScale))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding()
                                Text("一共答对了\(correctAnswers)题")
                                    .font(.system(size:80 * AppConfigs.cardFrontFontSizeScale))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .padding()
                            }
                            Spacer()

                        } else {}
                        
                    }
                    // 确保内容在旋转前能完整显示
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                // 应用旋转效果，在竖屏模式下模拟横屏显示
                    .rotationEffect(.degrees(90))
                    // 确保有足够空间显示多行文本
                    .frame(width: contentWidth * 0.8, height: contentHeight)
                    // 绝对定位确保在屏幕中央
                    .position(x: centerX, y: centerY)

                }
                // 整个屏幕的点击手势，用于显示返回按钮
                .onTapGesture {
                    showBackButton()
                }
                // 监听方向变化通知
            .onAppear {
                // 初始化 Core Motion 管理器
                motionManager = CMMotionManager()
                // 在iOS 13+中，需要先请求权限再使用Core Motion
                // 创建CMMotionActivityManager用于权限请求
                let activityManager = CMMotionActivityManager()
                
                // 检查运动活动是否可用
                if CMMotionActivityManager.isActivityAvailable() {
                    // 检查权限状态
                    let authorizationStatus = CMMotionActivityManager.authorizationStatus()
                    
                    switch authorizationStatus {
                    case .authorized:
                        // 已授权，直接启动加速计更新
                        startAccelerometerUpdates()
                    case .notDetermined:
                        // 未确定，请求权限
                        // 在实际项目中，这里应该先向用户解释为什么需要这个权限
                        // 然后在用户点击确认后再请求
                        requestMotionPermission()
                    case .denied:
                        // 已拒绝，提示用户去设置中打开权限
                        print("Core Motion权限已被拒绝，请在设置中打开")
                    @unknown default:
                        print("未知的权限状态")
                    }
                } else {
                    print("设备不支持Core Motion功能")
                }
            }
            // 视图消失时清理资源
            .onDisappear {
                releaseResource()
            }
        }
    }

    // 显示返回按钮，并设置3秒后自动隐藏
    private func showBackButton() {
        // 清除之前的定时器
        backButtonTimer?.invalidate()
        
        // 立即显示返回按钮
        withAnimation(.easeOut(duration: 0.3)) {
            backButtonOpacity = 1
        }
        
        // 设置3秒后自动隐藏
        backButtonTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {
            [self] _ in
            withAnimation(.easeIn(duration: 0.5)) {
                backButtonOpacity = 0
            }
        }
    }
    
    // 处理屏幕翻转
    private func handleScreenRotation() {
        // 只有在游戏进行中才处理翻转
        if currentStage != .gameStarted || (showSkip || showCorrect) {
            return
        }
        
        // 屏幕朝下或朝上
        if screenDirection == .screenUp || screenDirection == .screenDown {
            if screenDirection == .screenDown {
                showCorrect = true
                showSkip = false
                MusicPlayer.shared.playAudio(named: "check.m4a")
                correctAnswers += 1
            } else {
                showSkip = true
                showCorrect = false
                MusicPlayer.shared.playAudio(named: "fail.m4a")
            }
        }
    }
    
    // 开始准备倒计时
    private func startReadyCountdown() {
        currentStage = .isReady
        readyCountdown = 3
        MusicPlayer.shared.playAudio(named: "count.m4a")
        // 清除之前的定时器
        readyTimer?.invalidate()
        // 创建新的定时器
        readyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [self] timer in
            
            readyCountdown -= 1
            // TODO: 来点音效
            if readyCountdown <= 0 {
                timer.invalidate()
                startGame()
            }
        }
    }
    
    // 开始游戏
    private func startGame() {
        currentStage = .gameStarted
        gameCountdown = duration
        currentCardIndex = 0
        correctAnswers = 0
        
        // 清除之前的定时器
        gameTimer?.invalidate()
        
        // 创建游戏倒计时定时器
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [self] timer in
            
            gameCountdown -= 1
            if gameCountdown <= 0 {
                timer.invalidate()
                endGame(playVoice: true)
            }
        }
    }
    
    // 结束游戏
    private func endGame(playVoice: Bool) {
        backButtonOpacity = 1
        currentStage = .gameEnded
        gameTimer?.invalidate()
        releaseResource()
        if (playVoice) {
            MusicPlayer.shared.playAudio(named: "game_end.m4a")
        }
    }

    private func releaseResource() {
        readyTimer?.invalidate()
        gameTimer?.invalidate()
        backButtonTimer?.invalidate()
        // 停止 Core Motion 更新
        if let motionManager = motionManager {
            motionManager.stopAccelerometerUpdates()
        }
    }
}
