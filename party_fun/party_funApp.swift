//
//  party_funApp.swift
//  party_fun
//
//  Created by Gongliang Zhang on 2025/9/5.
//

import SwiftUI

@main
struct party_funApp: App {
    init() {
        // 在应用启动时增加启动次数
        AppRatingManager.shared.incrementLaunchCount()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}
