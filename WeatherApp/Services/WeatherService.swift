//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/4/24.
//

import Foundation
import Combine

class WeatherService {
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather?&"
    private let apiKey = ""
    
    // This function now returns a publisher instead of using a callback
    func getWeatherPublisher(for city: String) -> AnyPublisher<WeatherData, Error> {
        if apiKey == "" {
            print("error apiKey, you need create a new apiKey.")
        }
        guard let url = makeURL(for: city) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func makeURL(for city: String) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"), // Use metric units
            URLQueryItem(name: "lang", value: "en")
        ]
        return components?.url
    }
}
