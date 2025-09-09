import SwiftUI

// 答案视图组件 - 用于显示可点击查看的答案内容
struct AnswerView: View {
    let line: String
    let foregroundColor: Color
    var width: CGFloat
    var alignment: TextAlignment = .center // 默认居中对齐
    
    @State private var isShowingAnswer = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            // 左对齐不需要左侧Spacer
            if alignment == .center || alignment == .right {
                Spacer() // 右侧对齐或居中时，左侧添加Spacer
            }
            
            Button(action: {
                isShowingAnswer.toggle()
            }) {
                Text(isShowingAnswer ? line : "点击查看答案")
                    .font(.system(size: 18 * AppConfigs.cardFrontFontSizeScale))
                    .fontWeight(.bold)
                    .foregroundColor(foregroundColor)
                    .underline(true, color: foregroundColor)
                    .minimumScaleFactor(0.5) // 允许字体缩小到原大小的50%
                    .lineLimit(nil) // 允许多行显示
            }
            
            // 右对齐不需要右侧Spacer
            if alignment == .center || alignment == .left {
                Spacer() // 左侧对齐或居中时，右侧添加Spacer
            }
        }
        .frame(width: width) // 限制宽度，防止超出卡片
    }
}