import SwiftUI

struct MultiLineView: View {
    var lines: [Line]
    var foregroundColor: Color
    var width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                // 使用LineView组件显示一行内容
                LineView(line: line, foregroundColor: foregroundColor, width: width)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(width: width) // 自动处理nil值
        .minimumScaleFactor(0.5)
        .lineLimit(nil)
    }
}