//
//  CityListView.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 12/16/24.
//

import SwiftUI

struct CityListView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @StateObject private var locationManager = LocationManager()
    @Binding var isPresented: Bool // Dismiss the view
    @State private var isSearchPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.cityList.isEmpty {
                    VStack {
                        Text("No cities added yet.")
                            .foregroundColor(.gray)
                        Button("Add City") {
                            isSearchPresented = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(viewModel.cityList, id: \.self) { city in
                            if let cityWeather = viewModel.cityWeatherData[city] {
                                Button(action: {
                                    viewModel.fetchWeather(for: city)
                                    isPresented = false
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(cityWeather.cityName)
                                                .font(.headline)
                                            Text("Temp: \(Int(cityWeather.temperature))° | Feels Like: \(Int(cityWeather.feelsLike))°")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        VStack {
                                            Text("H: \(Int(cityWeather.highTemp))°")
                                                .font(.caption)
                                            Text("L: \(Int(cityWeather.lowTemp))°")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            } else {
                                // Placeholder when weather data is still loading
                                HStack {
                                    Text(city)
                                        .font(.headline)
                                    Spacer()
                                    ProgressView() // Show loading indicator
                                }
                            }
                        }
                        .onDelete(perform: deleteCity)
                        .onAppear {
                            viewModel.fetchWeatherForCities() // Fetch weather for all cities on view load
                        }
                    }
                }
            }
            .navigationTitle("Cities") // Dynamically set title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Left side close button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false // Dismiss the CityListView
                    }) {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                
                // Right side add (+) button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSearchPresented.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.subheadline) // Adjust size
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $isSearchPresented) {
                LocationSearchView(
                    viewModel: viewModel,
                    locationManager: locationManager,
                    isPresented: $isSearchPresented,
                    selectedCity: $viewModel.cityName
                )
            }
        }
    }
    
    private func deleteCity(at offsets: IndexSet) {
        offsets.map { viewModel.cityList[$0] }.forEach { viewModel.removeCity($0) }
    }
}
