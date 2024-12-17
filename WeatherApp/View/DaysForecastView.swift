//
//  DaysForecastView.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 12/11/24.
//

import SwiftUI
import MapKit

struct DaysForecastView: View {
    
    @ObservedObject var viewModel: WeatherViewModel // Use the shared view model
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack() {
                    Image(systemName: "calendar")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    
                    Text("Daily Forecast")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                        ForEach(viewModel.nextFourDaysForecast) { forecast in
                            DayBlockView(icon: forecast.weatherCode,
                                             date: forecast.formattedDate,
                                             temp_min: forecast.lowTemp,
                                             temp_max: forecast.highTemp,
                                             rainPercentage: forecast.rainPercentage)
                        }
                    }
                    .padding(.top, 5)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0)
            }
        }
    }
}

struct DayBlockView: View {
    var icon: String
    var date: String
    var temp_min: Double
    var temp_max: Double
    var rainPercentage: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(date)
                .font(.caption)
                .foregroundColor(.white)
            
            WeatherIconView(sizeIcon: 30, weatherCode: icon)
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.white.opacity(0.2)))
            
            HStack(spacing: 5) {
                Text("\(Int(temp_min))°")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text("\(Int(temp_max))°")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 5) {
                Image(systemName: "cloud.rain.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                
                // Display rain percentage
                Text(rainPercentage)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }
}

// Preview with mock data
struct DaysForecastView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = WeatherViewModel()
        mockViewModel.cityName = "New York"
        mockViewModel.temperature = 25
        mockViewModel.lowTemp = 15
        mockViewModel.highTemp = 30
        mockViewModel.feelsLike = 22
        mockViewModel.humidity = 60
        mockViewModel.windSpeed = 15
        mockViewModel.pressure = 1013
        
        return DaysForecastView(viewModel: mockViewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
