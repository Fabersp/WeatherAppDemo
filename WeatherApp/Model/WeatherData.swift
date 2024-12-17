//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/4/24.
//
import Foundation

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct WeatherData: Codable {
    let coord: Coord
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Main: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let feels_like: Double
    let humidity: Int
    let pressure: Int
        
    var tempInt: Int { return Int(temp) }
    var tempMinInt: Int { return Int(temp_min) }
    var tempMaxInt: Int { return Int(temp_max) }
    var feels_likeInt: Int { return Int(feels_like) }
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double

    // Convert speed to a user-friendly format
    var speedInKmh: Double {
        return speed * 3.6 // Convert m/s to km/h
    }
}

struct CityWeather: Identifiable {
    let id = UUID()
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let highTemp: Double
    let lowTemp: Double
}

