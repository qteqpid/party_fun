import SwiftUI

// 定义卡片数据模型
struct Game: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let cardBackground: String
    let isEnabled: Bool
}