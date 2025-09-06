import SwiftUI

// 为Card.splitBody专门设计的视图组件
struct SplitBodyView: View {
    var card: Card
    var foregroundColor: Color
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        // 显示splitBody内容
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array((card.splitBody ?? []).enumerated()), id: \.offset) { index, line in
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(line.words.enumerated()), id: \.offset) { _, word in
                        Text(word.content)
                            .font(.system(size: word.fontSize))
                            .fontWeight(.bold)
                            .foregroundColor(foregroundColor)
                            .underline(word.hasUnderline, color: foregroundColor)
                    }
                    Spacer() // 确保每行内容左对齐
                }.border(.red)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: width, height: height)
        .minimumScaleFactor(0.5)
        .lineLimit(nil)
    }
}