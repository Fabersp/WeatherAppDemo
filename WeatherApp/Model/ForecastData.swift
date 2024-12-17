//
//  ForecastData.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 12/9/24.
//

import Foundation

// Main model for 5-day forecast data
struct ForecastData: Codable {
    let list: [Forecast]
    let city: City
}

struct Forecast: Codable {
    let dt: Int // Timestamp
    let main: Main
    let weather: [Weather]
    let pop: Double? // Probability of precipitation (optional)
    
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E ha" // Example: Mon 9 AM
        return formatter.string(from: date)
    }
    
    var rainPercentage: String {
        if let pop = pop {
            return "\(Int(pop * 100))%" // Convert to percentage
        }
        return ""
    }
}

struct City: Codable {
    let name: String
    let country: String
}


struct DailyForecast: Identifiable {
    var id: Date { date }
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let description: String
    let weatherCode: String
    let rainPercentage: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Example: Monday
        return formatter.string(from: date)
    }
}

