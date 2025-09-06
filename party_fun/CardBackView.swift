//  CardBackView.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI

struct CardBackView: View {
    let game: Game
    let rotationY: Double
    let cardWidth: CGFloat = AppConfigs.cardWidth
    let cardHeight: CGFloat = AppConfigs.cardHeight
    
    // 计算卡片是否应该显示（根据旋转角度）
    private var isVisible: Bool {
        let angle = rotationY.truncatingRemainder(dividingBy: 360)
        return angle < 90 || angle > 270
    }
    
    var body: some View {
        // 卡片背面 - 显示游戏图片的背景
        ZStack {
            // 白色圆角矩形背景
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
                .frame(width: cardWidth, height: cardHeight)
                .opacity(isVisible ? 1 : 0)
                .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
            
            // 背面图片
            if let image = AppConfigs.loadImage(name: game.cardBackground) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth - 20, height: cardHeight - 20)
                    .clipped()
                    .cornerRadius(15)
                    .opacity(isVisible ? 1 : 0)
                    .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
}