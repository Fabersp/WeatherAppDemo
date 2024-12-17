//
//  ForecastService.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 12/9/24.
//

import Foundation
import Combine

class ForecastService {
    private let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
    private let apiKey = ""
    
    // Fetch 5-day weather forecast for a given city
    func getForecastPublisher(lat: Double, lon: Double) -> AnyPublisher<ForecastData, Error> {
        if apiKey == "" {
            print("error apiKey, you need create a new apiKey.")
        }
        guard let url = makeURL(lat: lat, lon: lon) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ForecastData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func makeURL(lat: Double, lon: Double) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "en")
        ]
        return components?.url
    }
}

