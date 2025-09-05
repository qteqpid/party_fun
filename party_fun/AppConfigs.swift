import SwiftUI

import SwiftUI
import UIKit

struct AppConfigs {

    static let games: [Game] = {
        // 创建游戏实例
        var games = [
            Game(title: "聊天盲盒", cardBackground: "chat", dataFile: "chat", isEnabled: true),
            Game(title: "整蛊惩罚", cardBackground: "trick", dataFile: "trick", isEnabled: false),
            Game(title: "断句挑战", cardBackground: "cut", dataFile: "cut", isEnabled: false),
            Game(title: "你做我猜", cardBackground: "guess", dataFile: "guess", isEnabled: false),
            Game(title: "喝酒之弈", cardBackground: "drink", dataFile: "drink", isEnabled: false),
            Game(title: "表情猜猜乐", cardBackground: "emoji", dataFile: "emoji", isEnabled: false)
        ]
        
        // 立即加载所有启用的游戏的卡片数据
        for i in 0..<games.count where games[i].isEnabled {
            games[i].loadCards()
        }
        
        return games
    }()

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