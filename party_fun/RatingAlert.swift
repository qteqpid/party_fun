//
//  RatingAlert.swift
//  party_fun
//
//  Created by AI Assistant on 2024/10/15.
//

import SwiftUI
import StoreKit

struct RatingAlert: ViewModifier {
    @Environment(\.requestReview) var requestReview
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert("你觉得app体验如何？", isPresented: $isPresented) {
                Button("一般") {}
                Button("还不错") {
                    requestReview()
                }
            } message: {
                Text("觉得还不错的话帮忙打个分吧~ 😘")
                    .font(.body)
                    .foregroundColor(Color.primary)
            }
    }
}

// 添加View扩展，方便使用这个自定义修饰符
extension View {
    func ratingAlert(isPresented: Binding<Bool>) -> some View {
        self.modifier(RatingAlert(isPresented: isPresented))
    }
}
