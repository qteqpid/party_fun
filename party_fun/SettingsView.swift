//  SettingsView.swift
//  party_fun
//
//  Created by AI Assistant on 2024/10/17.
//

import SwiftUI
import UIKit
import Combine

// 应用信息模型
struct AppInfo {
    let iconName: String
    let title: String
    let appleId: String
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    var backgroundColor: Color
    private let settingHeaderColor = Color(red: 0.99, green: 0.98, blue: 0.95)
    
    // 应用列表数据
    private let apps: [AppInfo] = [
        AppInfo(iconName: "app_logo_moon_mini.jpg", title: "海龟汤来了，风靡全球推理游戏", appleId: "6749227316"),
        AppInfo(iconName: "app_logo_idea_mini.png", title: "灵光一现，帮你随时记录想法", appleId: "6748610782"),
        AppInfo(iconName: "app_logo_english_mini.jpg", title: "背单词来了，学英语很简单", appleId: "6748849691"),
        AppInfo(iconName: "app_logo_class_mini.jpg", title: "课程表来了，学生家长教师必备", appleId: "6748935753"),
        AppInfo(iconName: "app_logo_chinese_mini.png", title: "汉字卡片，幼儿识字好帮手", appleId: "6753268205"),
        AppInfo(iconName: "app_logo_math_mini.jpg", title: "小学生口算练习", appleId: "6748607355"),
        AppInfo(iconName: "app_logo_passbox_mini.png", title: "密码柜，生活密码好记星", appleId: "6748747342"),
        AppInfo(iconName: "app_logo_cleaner_mini.png", title: "相册清理助手", appleId: "6748892725"),
        AppInfo(iconName: "app_logo_draw_mini.png", title: "绘图白板", appleId: "6749177569")
    ]
    
    // 使用map将应用数据转换为视图数组
    private var appViews: [AnyView] {
        apps.map { app in
            AnyView(
                SettingsRow(iconName: app.iconName, title: app.title, isLast: false) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    AppConfigs.openUrl(url: AppConfigs.getAppStoreUrl(appId: app.appleId))
                }
            )
        }
    }
    
    var body: some View {
        ZStack {
            // 背景色
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            // 主内容
            VStack {
                // 设置列表
                List {
                   Section() {
                       // 使用ForEach遍历视图数组，实现map + foreach的展示方式
                       ForEach(appViews.indices, id: \.self) { index in
                           appViews[index]
                       }
                   }

                    // 联系我们分组
                   Section(header: Text("联系我们").foregroundColor(settingHeaderColor).font(.title2)) {
                       // 自定义组件用于打开小红书App
                       SettingsRow(iconName: "rednote_icon.png", title: "Qteqpid", isLast: false) {
                           Image(systemName: "chevron.right")
                               .foregroundColor(.gray)
                       }
                       .onTapGesture {
                            // 小红书App的URL Scheme
                           AppConfigs.openUrl(url: "https://xhslink.com/m/6ooRgc36BTt")
                       }
                       SettingsRow(iconName: "email_icon.png", title: "glloveyp@163.com", isLast: true) {
                            EmptyView()
                       }
                    
                   }
                    
                    // 其他分组
                   Section(header: Text("其他").foregroundColor(settingHeaderColor).font(.title2)) {
                       SimpleSettingsRow(iconName: "star", title: "给我们评分", isLast: false)
                        .onTapGesture {
                            // app store评分界面
                            AppConfigs.openUrl(url: "itms-apps://itunes.apple.com/app/id6752017904?action=write-review")
                        }
                       SettingsRowWithText(iconName: "info.circle", title: "版本号", text: AppConfigs.appVersion, isLast: true)
                   }
                }
                .background(backgroundColor)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
        }
        .navigationTitle("Qteqpid的更多宝藏作品")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
            }
        }
        
    }
}
