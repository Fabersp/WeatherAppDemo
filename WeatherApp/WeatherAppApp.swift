//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/4/24.
//

import SwiftUI

@main
struct WeatherApp: App {

    init() {
        // Customize navigation bar appearance
        updateNavigationBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            WeatherView()
                .onAppear {
                    updateNavigationBarAppearance()
                }
        }
    }

    private func updateNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        let accentColor = UIColor(named: "BGColor")
        appearance.backgroundColor = accentColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().topItem?.leftBarButtonItem?.tintColor = .white
    }
}
