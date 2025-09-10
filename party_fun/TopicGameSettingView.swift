import SwiftUI

// 游戏设置弹窗视图
struct TopicGameSettingView: View {
    let topic: Topic
    let onStartGame: (_ duration: Int) -> Void
    let onDismiss: () -> Void
    
    // 游戏时长选项，单位：秒
    private let durationOptions = [60, 120, 180, 240, 300]
    
    @State private var selectedDurationIndex = 2 // 默认选择180秒（3分钟）
    
    var body: some View {
        ZStack {
            // 增强虚化背景效果
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .blur(radius: 40) // 增加模糊半径使效果更明显
                .onTapGesture {
                    onDismiss()
                }
            
            // 弹窗容器
            VStack {
                // 弹窗内容
                VStack {
                    // 主题名称和描述
                    VStack {
                        Text(topic.topicName) // 显示主题名称
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.top, 20)
                        
                        Text("欢迎来到\(topic.topicName)!\n各种内容应有尽有，这是人人都能参与的趣味词库。")
                            .font(.body)
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                    
                    // 游戏时长选择器
                    VStack {
                        Text("请选择每局时长")
                            .font(.headline)
                            .foregroundColor(Color.white)
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
                                .accentColor(Color.yellow)
                                
                                // 自定义圆形节点，覆盖在滑块上
                                HStack(alignment: .center, spacing: 0) {
                                    ForEach(0..<durationOptions.count, id: \.self) {
                                        index in
                                        Circle()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(index <= selectedDurationIndex ? Color.yellow : Color.gray.opacity(0.5))
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
                                    .font(.caption)
                                    .foregroundColor(index == selectedDurationIndex ? Color.yellow : Color.white)
                                if index < durationOptions.count - 1 {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    
                    // 按钮区域
                    HStack {
                        Button(action: {
                            onDismiss()
                        }) {
                            Text("返回")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.7))
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // 调用开始游戏回调，传递选择的时长
                            onStartGame(durationOptions[selectedDurationIndex])
                        }) {
                            Text("开始")
                                .font(.headline)
                                .foregroundColor(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .background(Color.green)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(20)
                .onTapGesture {}
            }
        }
    }
}
