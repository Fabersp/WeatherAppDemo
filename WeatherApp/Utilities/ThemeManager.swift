//
//  ThemeManager.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 12/5/24.
//

import SwiftUI

struct ThemeManager {
    // Static properties for light and dark colors
    static let lightBackground = Color.white
    static let darkBackground = Color.black
    
    // A helper function to get the appropriate background color dynamically
    static func appBackground(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return darkBackground
        } else {
            return Color(UIColor(named: "BGColor") ?? UIColor.systemBlue)
        }
    }
    
    // A helper function to create a gradient background
    static func appGradient(for colorScheme: ColorScheme) -> LinearGradient {
        let topColor: Color = colorScheme == .dark ? darkBackground : Color(UIColor(named: "BGColor") ?? UIColor.systemBlue)
        let bottomColor: Color = colorScheme == .dark ? darkBackground : Color.blue.opacity(0.6)
        
        return LinearGradient(
            gradient: Gradient(colors: [topColor, bottomColor]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
