import SwiftUI

// 定义卡片数据模型
struct Game: Identifiable {
    let id = UUID()
    let title: String
    let cardBackground: String
    let dataFile: String
    let isEnabled: Bool
    var cards: [Card] = []


    mutating func loadCards() {
        guard let url = Bundle.main.url(forResource: self.dataFile, withExtension: "json") else {
            print("找不到\(self.dataFile).json文件")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // 根据实际JSON结构调整解码方式
            // 假设JSON包含一个cards数组
            let decodedCards = try decoder.decode([Card].self, from: data)
            cards = decodedCards.shuffled()
        } catch {
            // 加载失败时使用模拟数据
            print("加载卡片数据失败: \(error.localizedDescription)")
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
    let words: [Word]
}
struct Card: Decodable {
    let title: String
    let body: String
    let splitBody: [Line]?
}
