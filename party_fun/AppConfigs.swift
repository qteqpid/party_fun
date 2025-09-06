import SwiftUI

import SwiftUI
import UIKit

struct AppConfigs {

    static var gameCoverWidth: CGFloat {
        // 返回屏幕宽度除以3
        if isIphone {
            return UIScreen.main.bounds.width / 3
        } else {
            return UIScreen.main.bounds.width / 4
        }
    }

    static var gameCoverHeight: CGFloat {
        return gameCoverWidth * 4 / 3
    }

    static var cardWidth: CGFloat {
        // 返回屏幕宽度除以3
        if isIphone {
            return UIScreen.main.bounds.width * 3 / 4
        } else {
            return UIScreen.main.bounds.width / 2
        }
    }

    static var cardHeight: CGFloat {
        return cardWidth * 4 / 3
    }

    static var appTitleSize: CGFloat {
        // 返回屏幕宽度除以3
        if isIphone {
            return 30
        } else {
            return 60
        }
    }

    static var bgImage: String {
        // 返回屏幕宽度除以3
        if isIphone {
            return "app_bg.png"
        } else {
            return "app_bg_pad.jpg"
        }
    }

    static var isIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    static let games: [Game] = {
        // 创建游戏实例 - 为所有游戏添加cardForeground参数
        var games = [
            Game(title: "聊天盲盒", cardBackground: "chat.png", cardForeground: nil, dataFile: "chat", isEnabled: true),
            Game(title: "整蛊惩罚", cardBackground: "trick.png", cardForeground: nil, dataFile: "trick", isEnabled: false),
            Game(title: "断句挑战", cardBackground: "cut.png", cardForeground: nil, dataFile: "cut", isEnabled: false),
            Game(title: "你做我猜", cardBackground: "guess.png", cardForeground: (nil, "#ffffff"), dataFile: "guess", isEnabled: false),
            Game(title: "喝酒之弈", cardBackground: "drink.png", cardForeground: ("drink_card.jpg", "#ffffff"), dataFile: "drink", isEnabled: false),
            Game(title: "表情猜猜乐", cardBackground: "emoji.png", cardForeground: nil, dataFile: "emoji", isEnabled: false)
        ]
        
        // 立即加载所有启用的游戏的卡片数据
        for i in 0..<games.count where games[i].isEnabled {
            games[i].loadCards()
            games[i].loadCardForeground()
        }
        
        return games
    }()


    static func loadImage(name: String?) -> UIImage? {
        guard let name = name else {
            print("图片名称为空")
            return nil
        }
        
        // 解析文件名和扩展名
        let components = name.split(separator: ".")
        if components.count != 2 {
            print("无效的图片名称格式: \(name)")
            return nil
        }
        
        let imageName = String(components[0])
        let imageType = String(components[1])
        
        // 使用解析出的文件名和扩展名加载图片
        if let filePath = Bundle.main.path(forResource: imageName, ofType: imageType) {
            return UIImage(contentsOfFile: filePath)
        }
        
        print("无法加载图片: \(name)")
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
