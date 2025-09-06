//  ButtonView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI

struct ButtonView: View {
    let isActive: Bool
    let onButtonTap: () -> Void
    let buttonWidth: CGFloat = 150
    let buttonHeight: CGFloat = 150
    
    var body: some View {
        Button {
            onButtonTap()
        } label: {
            if let buttonImg = AppConfigs.loadImage(name: "button.png") {
                Image(uiImage: buttonImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonWidth, height: buttonHeight)
                    .overlay(
                        Text(isActive ? "STOP" : "START")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(isActive ? Color(hex: "#831c21") : Color.white)
                            .shadow(radius: 2)
                    )
                    .scaleEffect(isActive ? 0.9 : 1.0)
                    .opacity(isActive ? 0.9 : 1.0)
                    .shadow(radius: isActive ? 8 : 5)
                    .animation(.easeInOut(duration: 0.3), value: isActive)
            } else {
                Circle()
                    .fill(isActive ? Color.red : Color.blue)
                    .scaleEffect(isActive ? 0.9 : 1.0)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .shadow(radius: isActive ? 15 : 10)
                    .overlay(
                        Text(isActive ? "停止翻牌" : "开始翻牌")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    )
                    .animation(.easeInOut, value: isActive)
            }
        }
    }
}