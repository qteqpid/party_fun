import SwiftUI

import SwiftUI
import UIKit

struct AppConfigs {
    
    static let isDebug = false
    
    static var cardFrontFontSizeScale: CGFloat {
        if isIphone {
            return 1.0
        } else {
            // 调整iPad上的字体缩放比例，使用2.0而不是5.0，避免过大导致被自动缩小
            return 2.0
        }
    }

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
            // 增加iPad上的卡片宽度，以便更好地显示放大的字体
            return UIScreen.main.bounds.width * 2 / 3
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
            Game(title: "聊天盲盒", cardBackground: "chat.png", cardForeground: nil, dataFile: "chat", isEnabled: true, gameName: .chat),
            Game(title: "喝酒之弈", cardBackground: "drink.png", cardForeground: ("drink_front.png", "#ffffff"), dataFile: "drink", isEnabled: true, gameName: .drink),
            Game(title: "海龟汤来了", cardBackground: "haigui.jpg", cardForeground: ("haigui_front.png", "#ffffff"), dataFile: "haigui", isEnabled: true, gameName: .haigui),
            Game(title: "整蛊惩罚", cardBackground: "trick.png", cardForeground: nil, dataFile: "trick", isEnabled: false, gameName: .trick),
            Game(title: "断句挑战", cardBackground: "cut.png", cardForeground: nil, dataFile: "cut", isEnabled: false, gameName: .cut),
            Game(title: "你做我猜", cardBackground: "guess.png", cardForeground: (nil, "#ffffff"), dataFile: "guess", isEnabled: false, gameName: .guess),
            Game(title: "表情猜猜乐", cardBackground: "emoji.png", cardForeground: nil, dataFile: "emoji", isEnabled: false, gameName: .emoji)
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
    // 修复版本 - 使用非可失败初始化器，并增加对各种十六进制格式的支持
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        // 处理#前缀
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        
        // 支持3位、6位和8位十六进制格式
        var hexValue: UInt64 = 0
        
        if Scanner(string: hex).scanHexInt64(&hexValue) {
            var r, g, b, a: Double
            
            switch hex.count {
            case 3: // RGB (12-bit)
                r = Double((hexValue & 0xF00) >> 8) / 15.0
                g = Double((hexValue & 0x0F0) >> 4) / 15.0
                b = Double(hexValue & 0x00F) / 15.0
                a = 1.0
            case 6: // RGB (24-bit)
                r = Double((hexValue & 0xFF0000) >> 16) / 255.0
                g = Double((hexValue & 0x00FF00) >> 8) / 255.0
                b = Double(hexValue & 0x0000FF) / 255.0
                a = 1.0
            case 8: // RGBA (32-bit)
                r = Double((hexValue & 0xFF000000) >> 24) / 255.0
                g = Double((hexValue & 0x00FF0000) >> 16) / 255.0
                b = Double((hexValue & 0x0000FF00) >> 8) / 255.0
                a = Double(hexValue & 0x000000FF) / 255.0
            default:
                // 默认值 - 黑色
                r = 0.0
                g = 0.0
                b = 0.0
                a = 1.0
            }
            
            self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
        } else {
            // 如果解析失败，返回黑色
            self.init(red: 0.0, green: 0.0, blue: 0.0)
        }
    }
}
