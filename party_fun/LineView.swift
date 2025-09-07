//  LineView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI

// 行视图组件 - 用于显示一行文本内容
struct LineView: View {
    let line: Line
    let foregroundColor: Color
    var width: CGFloat
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(line.line.enumerated()), id: \.offset) { _, word in
                Text(word.content)
                    .font(.system(size: word.fontSize))
                    .fontWeight(.bold)
                    .foregroundColor(foregroundColor)
                    .underline(word.hasUnderline, color: foregroundColor)
                    .minimumScaleFactor(0.5) // 允许字体缩小到原大小的50%
                    .lineLimit(1) // 限制为单行，强制字体缩放而不是换行
            }
            Spacer() // 确保每行内容左对齐
        }
        .frame(width: width) // 限制宽度，防止超出卡片
    }
}
