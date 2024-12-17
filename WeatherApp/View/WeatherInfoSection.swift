//
//  WeatherInfoSection.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/7/24.
//

import SwiftUI

struct WeatherInfoSection: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        VStack(spacing: 10) {
            infoBlock {
                VStack(spacing: 5) { // Adjusted spacing
                    HStack {
                        if viewModel.isCurrentLocation {
                            VStack(spacing: 5) {
                                HStack {
                                    Text("My location")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "location.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.white)
                                }
                                Text(viewModel.cityName.capitalized)
                                    .font(.system(size: 25, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text(viewModel.cityName.capitalized)
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }

                    Text("\(Int(viewModel.temperature))°")
                        .font(.system(size: 90, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, -10) // Reduce vertical space

                    // Adjusted spacing for description
                    Text(viewModel.description)
                        .font(.system(size: 20, weight: .semibold)) // Slightly smaller font
                        .foregroundColor(.white)
                        .padding(.top, -10) // Reduce vertical space

                    HStack(spacing: 5) {
                        weatherH(iconName: "thermometer.low", label: "Min Temp", value: "\(Int(viewModel.lowTemp))°")
                        weatherH(iconName: "thermometer.high", label: "Max Temp", value: "\(Int(viewModel.highTemp))°")
                        weatherH(iconName: "thermometer.snowflake", label: "Feels Like", value: "\(Int(viewModel.feelsLike))°")
                    }
                }
            }
            
            infoBlock {
                HStack(spacing: 5) {
                    weatherH(iconName: "drop.fill", label: "Humidity", value: "\(viewModel.humidity)%")
                    weatherH(iconName: "wind", label: "Wind", value: "\(Int(viewModel.windSpeed)) km/h")
                    weatherH(iconName: "gauge", label: "Pressure", value: "\(Int(viewModel.pressure)) hPa")
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // Reusable block for each section
    private func infoBlock<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        VStack {
            content()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
        .shadow(radius: 8)
    }

    // Reusable weather stat view
    private func weatherH(iconName: String, label: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)

                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Preview with mock data
struct WeatherInfoSection_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = WeatherViewModel()
        mockViewModel.cityName = "New York"
        mockViewModel.description = "Cloud"
        mockViewModel.temperature = 25
        mockViewModel.lowTemp = 15
        mockViewModel.highTemp = 30
        mockViewModel.feelsLike = 22
        mockViewModel.humidity = 60
        mockViewModel.windSpeed = 15
        mockViewModel.pressure = 1013
        mockViewModel.isCurrentLocation = true
        
        return WeatherInfoSection(viewModel: mockViewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
