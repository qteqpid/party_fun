import SwiftUI

// 游戏设置弹窗视图
struct TopicGameSettingView: View {
    let topic: Topic
    let onStartGame: (_ duration: Int) -> Void
    let onDismiss: () -> Void
    
    // 游戏时长选项，单位：秒
    private let durationOptions = [60, 120, 180, 240, 300]
    private let bambooGreen = Color.green //Color(hex: "#809954")
    private let fontColor = Color(hex:"#2d2d2d")
    
    @State private var selectedDurationIndex = 2 // 默认选择180秒（3分钟）
    
    var body: some View {
        ZStack {
            // 带缩放动画的弹窗内容
            VStack {
                // 主题名称和描述
                VStack {
                    Text(topic.topicName) // 显示主题名称
                        .font(.system(size:30 * AppConfigs.cardFrontFontSizeScale))
                        .fontWeight(.bold)
                        .foregroundColor(fontColor)
                        .padding(.top, 20)
                    Spacer()
                    if let guideImage = AppConfigs.loadImage(name: "guess_guide.jpg") {
                        Image(uiImage: guideImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(4)
                    } else {
                            Text("欢迎来到\(topic.topicName)的词库!")
                            .font(.body)
                            .foregroundColor(fontColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .frame(width: AppConfigs.cardWidth - 20, height: AppConfigs.cardHeight / 2)

                Spacer()

                // 游戏时长选择器
                VStack {
                    Text("请选择每局时长")
                        .font(.system(size:20 * AppConfigs.cardFrontFontSizeScale))
                        .foregroundColor(fontColor)
                        .padding(.top, 10)
                        
                    HStack {
                        Spacer()
                        
                        // 滑块选择器
                        ZStack {
                            Slider(
                                value: Binding(
                                    get: { Double(selectedDurationIndex) },
                                    set: { selectedDurationIndex = Int($0.rounded()) }
                                ),
                                in: 0...Double(durationOptions.count - 1),
                                step: 1.0
                            )
                            .padding(.horizontal, 20)
                            .accentColor(bambooGreen)
                            
                            // 自定义圆形节点，覆盖在滑块上
                            HStack(alignment: .center, spacing: 0) {
                                ForEach(0..<durationOptions.count, id: \.self) {
                                    index in
                                    Circle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(index <= selectedDurationIndex ? bambooGreen : Color(hex:"#decc54"))
                                        .onTapGesture {
                                            selectedDurationIndex = index
                                        }
                                    if index < durationOptions.count - 1 {
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .offset(y: -2) // 微调垂直位置，使其完美覆盖在滑块上
                        }
                        
                        Spacer()
                    }
                    
                    // 时长标签
                    HStack {
                        ForEach(0..<durationOptions.count, id: \.self) {
                            index in
                            Text("\(durationOptions[index]/60)分钟")
                                .font(.system(size:10 * AppConfigs.cardFrontFontSizeScale))
                                .fontWeight(.bold)
                                .foregroundColor(index == selectedDurationIndex ? bambooGreen : fontColor)
                            if index < durationOptions.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
                
                // 按钮区域
                HStack {
                    Button(action: {
                        onDismiss()
                    }) {
                        Text("返回")
                            .font(.system(size:20 * AppConfigs.cardFrontFontSizeScale))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            )
                    }
                    
                    Button(action: {
                        // 调用开始游戏回调，传递选择的时长
                        onStartGame(durationOptions[selectedDurationIndex])
                    }) {
                        Text("开始")
                            .font(.system(size:20 * AppConfigs.cardFrontFontSizeScale))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            )
                    }
                }
                .padding()
            }
            .background {
                // 第一层：厚重的阴影背景
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: AppConfigs.cardWidth + 8, height: AppConfigs.cardHeight + 8)
                    .offset(y: 4)
                
                // 第二层：白色圆角矩形背景
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)

                // 第三层：卡片内容背景
                if let bgImage = AppConfigs.loadImage(name: "topic_bg.jpg") {
                    Image(uiImage: bgImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: AppConfigs.cardWidth - 12, height: AppConfigs.cardHeight - 12)
                        .cornerRadius(18)
                        .accessibility(hidden: true) // 对辅助功能隐藏
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.3), lineWidth: 2))
                } else {
                    Color.yellow
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.3), lineWidth: 2))
                }
            }
            .frame(width: AppConfigs.cardWidth, height: AppConfigs.cardHeight)
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 12)
            .padding(20)
            .onTapGesture {}
            
        }
        .onTapGesture {
            onDismiss()
        }
    }
}
