//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/4/24.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var cityName: String = ""
    @Published var temperature: Double = 0
    @Published var description: String = ""
    @Published var highTemp: Double = 0
    @Published var lowTemp: Double = 0
    @Published var windSpeed: Double = 0.0
    @Published var humidity: Int = 0
    @Published var pressure: Int = 0
    @Published var feelsLike: Double = 0.0
    @Published var weatherCode: String = ""
    @Published var forecast: [Forecast] = []
    @Published var error: String?
    @Published var isLoading: Bool = false
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var isCurrentLocation: Bool = true // Tracks if the city is user's location
    @Published var cityList: [String] = [] // List of saved cities
    @Published var cityWeatherData: [String: CityWeather] = [:] // Stores weather data for cities
    
    private let weatherService = WeatherService()
    private let forecastService = ForecastService()
    private var cancellables = Set<AnyCancellable>()
    private var detectedCityName: String = "" // Tracks the actual city detected by LocationManager
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    private let storageKey = "SavedCities"
    
    init() {
        loadSavedCities()
        setupiCloudObserver()
    }
    
    func updateCityName(from locationManager: LocationManager) {
        detectedCityName = locationManager.city
        isCurrentLocation = cityName.lowercased() == detectedCityName.lowercased()
    }
    
    var dailyForecasts: [Forecast] {
        let sortedForecasts = forecast.sorted { $0.date < $1.date } // Sort forecasts by date
        return Array(sortedForecasts.prefix(4)) // Take only the first 10 sorted forecasts
    }
    
    // Fetch current weather
    func fetchWeather(for city: String) {
        weatherService.getWeatherPublisher(for: city)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            }, receiveValue: { [weak self] weatherData in
                self?.updateCurrentWeather(with: weatherData)
                self?.addCityToList(city) // Add to list only if valid
                // Ensure latitude and longitude are set before fetching forecast
                if let latitude = self?.latitude, let longitude = self?.longitude {
                    self?.fetchForecast(lat: latitude, lon: longitude)
                }
            })
            .store(in: &cancellables)
    }
    
    // Fetch the forecast
    func fetchForecast(lat: Double, lon: Double) {
        isLoading = true
        forecastService.getForecastPublisher(lat: lat, lon: lon)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    print("Error fetching forecast: \(error)")
                }
            }, receiveValue: { [weak self] forecastData in
                self?.forecast = forecastData.list
            })
            .store(in: &cancellables)
    }
    
    func fetchWeatherForCities() {
        for city in cityList {
            weatherService.getWeatherPublisher(for: city)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching weather for \(city): \(error.localizedDescription)")
                    }
                }, receiveValue: { [weak self] weatherData in
                    let cityWeather = CityWeather(
                        cityName: weatherData.name,
                        temperature: weatherData.main.temp,
                        feelsLike: weatherData.main.feels_like,
                        highTemp: weatherData.main.temp_max,
                        lowTemp: weatherData.main.temp_min
                    )
                    self?.cityWeatherData[city] = cityWeather
                })
                .store(in: &cancellables)
        }
    }
    
    private func updateCurrentWeather(with data: WeatherData) {
        cityName = data.name
        temperature = data.main.temp
        description = data.weather.first?.description.capitalized ?? ""
        highTemp = data.main.temp_max
        lowTemp = data.main.temp_min
        windSpeed = data.wind.speed
        humidity = data.main.humidity
        pressure = data.main.pressure
        feelsLike = data.main.feels_like
        weatherCode = data.weather.first?.icon ?? ""
        latitude = data.coord.lat
        longitude = data.coord.lon
    }
    
    private func updateForecast(with data: ForecastData) {
        forecast = data.list
        cityName = "\(data.city.name), \(data.city.country)"
    }
    
    // MARK: - City List Management
    
    func addCityToList(_ city: String) {
        if !cityList.contains(city) {
            cityList.append(city)
            saveCitiesToiCloud()
        }
    }
    
    func removeCity(_ city: String) {
        cityList.removeAll { $0 == city }
        saveCitiesToiCloud()
    }
    
    private func saveCitiesToiCloud() {
        iCloudStore.set(cityList, forKey: storageKey)
        iCloudStore.synchronize()
    }
    
    private func loadSavedCities() {
        if let savedCities = iCloudStore.array(forKey: storageKey) as? [String] {
            cityList = savedCities
        }
    }
    
    private func setupiCloudObserver() {
        NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: iCloudStore,
                                               queue: .main) { [weak self] _ in
            self?.loadSavedCities()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension WeatherViewModel {
    /// Returns aggregated forecasts for the next 4 days
    var nextFourDaysForecast: [DailyForecast] {
        var dailyForecasts: [DailyForecast] = []
        let calendar = Calendar.current
        
        // Group forecasts by day
        let groupedByDay = Dictionary(grouping: forecast) { forecast in
            calendar.startOfDay(for: forecast.date)
        }
        
        // Sort by date and limit to 4 days
        let sortedDays = groupedByDay.keys.sorted().prefix(4)
        
        for day in sortedDays {
            if let forecastsForDay = groupedByDay[day] {
                // Aggregate high and low temperatures and take the first weather description
                let highTemp = forecastsForDay.max(by: { $0.main.temp_max < $1.main.temp_max })?.main.temp_max ?? 0
                let lowTemp = forecastsForDay.min(by: { $0.main.temp_min < $1.main.temp_min })?.main.temp_min ?? 0
                let description = forecastsForDay.first?.weather.first?.description.capitalized ?? ""
                let weatherCode = forecastsForDay.first?.weather.first?.icon ?? ""
                let rainPercentage = forecastsForDay.first?.rainPercentage ?? ""
                
                let dailyForecast = DailyForecast(
                    date: day,
                    highTemp: highTemp,
                    lowTemp: lowTemp,
                    description: description,
                    weatherCode: weatherCode,
                    rainPercentage: rainPercentage
                )
                dailyForecasts.append(dailyForecast)
            }
        }
        return dailyForecasts
    }
}
