import SwiftUI

struct Word: Decodable, Equatable {
    let content: String
    let fontSize: CGFloat
    let hasUnderline: Bool?
}

struct Line: Decodable, Equatable {
    let line: [Word]
}

// 主题类型枚举
enum TopicType: String, Decodable, CaseIterable  {
    case animal
    case food
    case network
    case job
    case company
    case school
    case travel
    case year
    case items
    case chengyu
}

// 主题结构体，管理主题相关信息
struct Topic: Decodable, Equatable, Identifiable {
    let id = UUID()
    let topicType: TopicType
    let topicName: String
    let topicImage: String
}

struct Card: Decodable, Equatable {
    let title: Line?
    let subtitle: Line?
    let image: String?
    let body: [Line]?
    let body2: [Line]?
    let answer: String?
    let topicType: TopicType? // 改为使用TopicType而不是Topic
}

struct WodiCard: Decodable, Equatable {
    let normalWord: String
    let spyWord: String
}


// 游戏名称枚举
enum GameName: String, CaseIterable {
    case chat = "chat"
    case trick = "trick"
    case guess = "guess"
    case emoji = "emoji"
    case cut = "cut"
    case haigui = "haigui"
    case truth = "truth"
    case wodi = "wodi"
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
    let topics: [Topic]?
    var cards: [Card] = []
    var wodiCards: [WodiCard] = [] // 谁是卧底游戏的卡片数据
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
        // dataFile不是可选类型，直接使用
        guard let url = Bundle.main.url(forResource: dataFile, withExtension: "json") else {
            print("找不到\(dataFile).json文件")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // 根据游戏类型加载不同的数据
            if gameName == .wodi {
                wodiCards = try decoder.decode([WodiCard].self, from: data)
            } else {
                cards = try decoder.decode([Card].self, from: data)
            }
        } catch {
            // 加载失败时使用模拟数据
            print("[\(dataFile).json文件]加载卡片数据失败: \(error.localizedDescription)")
            cards = []
            wodiCards = []
        }
    }
}


