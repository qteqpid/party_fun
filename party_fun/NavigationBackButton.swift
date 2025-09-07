//  NavigationBackButton.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI

// 自定义导航栏返回按钮视图
struct NavigationBackButton: View {
    let label: String
    var body: some View {
        Button(action: {
            // 使用环境中的presentationMode来执行返回操作
            if let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
                navigationController.popViewController(animated: true)
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
    }
}