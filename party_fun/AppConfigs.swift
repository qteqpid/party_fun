import SwiftUI

import SwiftUI
import UIKit

struct AppConfigs {

    static let games = [
        Game(title: "聊天盲盒", description: "经典聚会游戏", cardBackground: "chat", isEnabled: true),
        Game(title: "整蛊惩罚", description: "考验演技与推理", cardBackground: "trick", isEnabled: false),
        Game(title: "断句挑战", description: "角色扮演推理游戏", cardBackground: "cut", isEnabled: false),
        Game(title: "你做我猜", description: "考验想象力和默契", cardBackground: "guess", isEnabled: false),
        Game(title: "喝酒之弈", description: "刺激有趣的指令游戏", cardBackground: "drink", isEnabled: false),
        Game(title: "表情猜猜乐", description: "猜谜游戏", cardBackground: "emoji", isEnabled: false)
    ]

    static let colorPairs = [
        ("#831c21", "#ffffff"),
        ("#ffffff", "#831c21"),
        ("#745e90", "#ffffff"),
        ("#f0894c", "#ffffff"),
        ("#458ea3", "#ffffff"),
        ("#9b5180", "#ffffff"),
        ("#93ab7d", "#ffffff"),
        ("#a3b09b", "#ffffff")
    ]

    static func loadImage(imageName: String, imageType: String) -> UIImage? {
        // 从bundle直接加载图片
        if let filePath = Bundle.main.path(forResource: imageName, ofType: imageType) {
            return UIImage(contentsOfFile: filePath)
        }
        print("无法加载图片"+imageName)
        return nil
    }
}




// 为Color添加从十六进制字符串创建的扩展
extension Color {
    init?(hex: String) {
        // 移除可能的#前缀
        let hexString = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        
        // 确保字符串长度正确
        guard hexString.count == 6 else {
            return nil
        }
        
        // 尝试解析十六进制值
        guard let rgbValue = UInt32(hexString, radix: 16) else {
            return nil
        }
        
        // 计算RGB值
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}