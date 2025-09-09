//  LineView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI

// 文本对齐方式枚举
enum TextAlignment { case left, center, right }

// 行视图组件 - 用于显示一行或多行文本内容
struct LineView: View {
    let line: Line
    let foregroundColor: Color
    var width: CGFloat
    var alignment: TextAlignment = .left // 默认左对齐
    var isSingleLine: Bool = true // 默认限制为单行
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            // 左对齐不需要左侧Spacer
            if alignment == .center || alignment == .right {
                Spacer() // 右侧对齐或居中时，左侧添加Spacer
            }
            
            ForEach(Array(line.line.enumerated()), id: \.offset) { _, word in
                Text(word.content)
                    .font(.system(size: word.fontSize * AppConfigs.cardFrontFontSizeScale))
                    .fontWeight(.bold)
                    .foregroundColor(foregroundColor)
                    .underline(word.hasUnderline, color: foregroundColor)
                    .minimumScaleFactor(0.5) // 允许字体缩小到原大小的50%
                    .modifier(LineLimitModifier(isSingleLine: isSingleLine))
            }
            
            // 右对齐不需要右侧Spacer
            if alignment == .center || alignment == .left {
                Spacer() // 左侧对齐或居中时，右侧添加Spacer
            }
        }
        .frame(width: width) // 限制宽度，防止超出卡片
    }
// 用于条件应用lineLimit的修饰符
struct LineLimitModifier: ViewModifier {
    let isSingleLine: Bool
    
    func body(content: Content) -> some View {
        if isSingleLine {
            content.lineLimit(1) // 限制为单行，强制字体缩放而不是换行
        } else {
            content.lineLimit(nil) // 允许多行显示
        }
    }
}

}
