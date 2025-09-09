import SwiftUI

// 游戏名称枚举
enum GameName: String, CaseIterable {
    case chat = "chat"
    case drink = "drink"
    case trick = "trick"
    case guess = "guess"
    case emoji = "emoji"
    case cut = "cut"
}

// 定义卡片数据模型
struct Game: Identifiable {
    let id = UUID()
    let title: String
    let cardBackground: String
    let cardForeground: (String?, String)? // 可选参数，用于卡片正面背景图片
    let dataFile: String
    let isEnabled: Bool
    let gameName: GameName // 新增字段，存储游戏名称枚举
    var cards: [Card] = []
    var cardForegroundImagePair: [(UIImage?, Color)] = []


    func imagePairs() -> [(UIImage?, Color)] {
        if !cardForegroundImagePair.isEmpty {
            return cardForegroundImagePair
        } else {
            return Game.defaultImagePairs
        }
    }

    // unused
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

    static let defaultImagePairs: [(UIImage?, Color)] = {
        var imagePairs: [(UIImage?, Color)] = []
        // 默认卡纸图片和颜色
        var pairs = [
            ("fg1.jpg", "#FBB917"),
            ("fg2.jpg", "#ffffff"),
            ("fg3.jpg", "#ffffff"),
            ("fg4.jpg", "#ffffff"),
            ("fg5.jpg", "#ffffff"),
            ("fg6.jpg", "#ffffff"),
            ("fg7.jpg", "#FBB917"),
            ("fg8.jpg", "#ffffff"),
            ("fg9.jpg", "#ffffff"),
            ("fg10.jpg", "#ffffff"),
            ("fg11.jpg", "#ffffff")
        ]
        
        
        for i in 0..<pairs.count {
            let image = AppConfigs.loadImage(name: pairs[i].0)
            imagePairs.append((image, Color(hex: pairs[i].1)))
        }
        
        return imagePairs
    }()

    var fgImage: UIImage?

    mutating func loadCardForeground() {
        if let cardForeground = self.cardForeground {
            fgImage = AppConfigs.loadImage(name: cardForeground.0)
            cardForegroundImagePair.append((fgImage, Color(hex: cardForeground.1)))
        }
    }

    mutating func loadCards() {
        guard let url = Bundle.main.url(forResource: self.dataFile, withExtension: "json") else {
            print("找不到\(self.dataFile).json文件")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // 假设JSON包含一个cards数组
            cards = try decoder.decode([Card].self, from: data)
        } catch {
            // 加载失败时使用模拟数据
            print("[\(self.dataFile).json文件]加载卡片数据失败: \(error.localizedDescription)")
            cards = []
        }
    }
}


struct Word: Decodable {
    let content: String
    let fontSize: CGFloat
    let hasUnderline: Bool
}

struct Line: Decodable {
    let line: [Word]
}
struct Card: Decodable {
    let title: Line?
    let subtitle: Line?
    let body: [Line]?
    let body2: [Line]?
}
