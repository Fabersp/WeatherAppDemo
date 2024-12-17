//
//  WeatherIconView.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 12/5/24.
//

import SwiftUI

struct WeatherIconView: View {
    var sizeIcon: Double
    var weatherCode: String
   
    @Environment(\.colorScheme) var colorScheme
    
    // Mapping weather codes to SF Symbol icons
    let weatherIconMapping: [String: String] = [
        "01d": "sun.max.fill",
        "01n": "moon.stars.fill",
        "02d": "cloud.sun.fill",
        "02n": "cloud.moon.fill",
        "03d": "cloud.fill",
        "03n": "cloud.fill",
        "04d": "cloud.fill",
        "04n": "cloud.fill",
        "09d": "cloud.drizzle.fill",
        "09n": "cloud.drizzle.fill",
        "10d": "cloud.sun.rain.fill",
        "10n": "cloud.moon.rain.fill",
        "11d": "cloud.bolt.rain.fill",
        "11n": "cloud.bolt.rain.fill",
        "13d": "snowflake",
        "13n": "snowflake",
        "50d": "cloud.fog.fill",
        "50n": "cloud.fog.fill"
    ]
    
    var body: some View {
        ZStack {
            // Dynamically load the SF Symbol based on weather code
            if let iconName = weatherIconMapping[weatherCode] {
                Image(systemName: iconName)
                    .foregroundStyle(gradientForWeatherCode(weatherCode))
                    .font(.system(size: sizeIcon))
                    .transition(.opacity) // Smooth transition for icons
            } else {
                // Default case if weather code is not mapped
                Image(systemName: "warning")
                    .foregroundStyle(gradientForWeatherCode(weatherCode))
                    .font(.system(size: sizeIcon))
                    .transition(.opacity) // Smooth transition for icons
            }
        }
    }
    
    // Gradient colors for different weather conditions
    func gradientForWeatherCode(_ code: String) -> LinearGradient {
        switch code {
        case "01d", "10d": // Sunny or partly cloudy during day
            return LinearGradient(colors: [.yellow, .white, .blue], startPoint: .top, endPoint: .bottom)
        case "01n", "10n", "03n", "04n": // Clear or partly cloudy at night
            return LinearGradient(colors: [.gray, .white, .blue], startPoint: .top, endPoint: .bottom)
        case "09d", "09n", "11d", "11n": // Rain or thunderstorms
            return LinearGradient(colors: [.gray, .blue], startPoint: .top, endPoint: .bottom)
        case "13d", "13n": // Snow
            return LinearGradient(colors: [.white, .blue.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        case "50d", "50n": // Mist or fog
            return LinearGradient(colors: [.gray, .white], startPoint: .top, endPoint: .bottom)
        default: // Default gradient for unmapped cases
            return LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom)
        }
    }
}
