import SwiftUI
import Foundation
import UIKit

// 扩展View以支持指定角的圆角设置
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// 自定义圆角形状
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// 游戏规则弹窗视图 - 优化版
struct GameRulePopupView: View {
    @Binding var isShowing: Bool
    let gameName: GameName
    
    private let buttonColor = Color(hex: "#EF504F")
    private let bgColor = Color(red:45/255.0, green: 45/255.0, blue: 45/255.0)
    var body: some View {
        VStack {
            // 游戏标题和内容
            let ruleDescription = GameRules.getRules(for: gameName)
            Spacer()
            // 标题文字
            Text(ruleDescription.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 15)
                .padding(.top, 15)
                
                
            // 规则内容区域 - 优化版
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // 游戏简介
                    Text("游戏规则说明：")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    
                    // 规则列表 - 美化版本
                    ForEach(Array(ruleDescription.rules.enumerated()), id: \.element) {
                        index, rule in
                        HStack(alignment: .top, spacing: 12) {
                            // 精美的数字图标
                            ZStack {
                                Circle()
                                    .fill(buttonColor)
                                    .frame(width: 28, height: 28)
                                Text(String(index + 1))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                            }
                            .shadow(radius: 2)
                            
                            // 规则文本 - 美化样式
                            Text(String(rule.dropFirst(2)))
                                .font(.body)
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(6)
                                .padding(.vertical, 4)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            
            // 底部关闭按钮 - 美化版
            HStack {
                Spacer()
                Button(action: {
                    // 添加点击动画
                    withAnimation(.spring()) {
                        isShowing.toggle()
                    }
                }) {
                    Text("我知道了")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 50)
                        .background(
                            buttonColor
                            .cornerRadius(30)
                            .shadow(radius: 4)
                        )
                        .scaleEffect(1.0)
                        .animation(.spring(), value: UUID())
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
                Spacer()
            }
        }
        .background {
            LinearGradient(
                gradient: Gradient(colors: [bgColor, bgColor]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
        }
        .animation(.spring(dampingFraction: 0.7), value: isShowing)
    }
    
}

// 游戏规则描述结构体
struct GameRuleDescription {
    let title: String
    let rules: [String]
}

// 游戏规则描述管理类
enum GameRules {
    // 获取指定游戏的规则描述
    static func getRules(for gameName: GameName) -> GameRuleDescription {
        switch gameName {
        case .chat:
            return GameRuleDescription(
                title: "聊天盲盒",
                rules: [
                    "1. 每位玩家轮流抽取一张卡片",
                    "2. 根据卡片上的话题进行交流讨论",
                    "3. 每个话题讨论时间为1-2分钟",
                    "4. 讨论过程中要坦诚分享，尊重他人的观点"
                ]
            )
        
        case .drink:
            return GameRuleDescription(
                title: "喝酒之弈",
                rules: [
                    "1. 玩家围坐一圈，轮流抽取卡片",
                    "2. 根据卡片上的指示进行游戏或饮酒",
                    "3. 可以根据个人情况适量饮酒",
                    "4. 请理性饮酒，注意安全",
                    "5. 未成年人请勿饮酒"
                ]
            )
        
        case .trick:
            return GameRuleDescription(
                title: "整蛊惩罚",
                rules: [
                    "1. 抽取惩罚卡片，按照指示完成惩罚",
                    "2. 惩罚内容应当适度，避免伤害他人",
                    "3. 被惩罚者可以选择替换惩罚，但须得到多数玩家同意",
                    "4. 游戏过程中保持轻松愉快的氛围"
                ]
            )
        
        case .guess:
            return GameRuleDescription(
                title: "你做我猜",
                rules: [
                    "1. 每轮游戏由至少两位成员完成",
                    "2. 表演者根据卡片上的词语进行表演，但不能说话",
                    "3. 同组其他成员根据表演猜测词语",
                    "4. 在规定时间内猜对最多的组获胜",
                    "5. 表演过程中不能使用与词语相关的语言"
                ]
            )
        
        case .emoji:
            return GameRuleDescription(
                title: "表情猜猜乐",
                rules: [
                    "1. 根据卡片上的emoji组合猜测词语或成语",
                    "2. 鼓励发挥想象力"
                ]
            )
        
        case .cut:
            return GameRuleDescription(
                title: "断句挑战",
                rules: [
                    "1. 一名玩家抽取一张断句卡片",
                    "2. 根据自己的理解为句子添加标点符号",
                    "3. 可以讨论不同断句方式带来的不同含义"
                ]
            )
            
        case .haigui:
            return GameRuleDescription(
                title: "海龟汤",
                rules: [
                    "1. 一名玩家作为出题人，抽取一张海龟汤卡片并查看汤底",
                    "2. 出题人只说出汤面（谜面），其他玩家轮流提问",
                    "3. 出题人只能用\"是\"、\"否\"、\"无关\"回答",
                    "4. 玩家通过提问逐步推理出完整的汤底"
                ]
            )
        
        case .truth:
            return GameRuleDescription(
                title: "真心话大冒险",
                rules: [
                    "1. 玩家轮流抽取卡片，根据卡片内容确定是真心话或大冒险",
                    "2. 若真心话，玩家必须如实回答其他人提的问题",
                    "3. 若大冒险，玩家必须完成其他人提的指定动作",
                    "4. 其他玩家监督并决定回答是否真诚、动作是否完成"
                ]
            )
        }
    }
}
