//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/4/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var isSearchPresented = false
    @State private var isCityListPresented = false
    @State private var selectedCity = "Current Location" // Default title
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    // Background gradient
                    ThemeManager.appGradient(for: colorScheme)
                        .edgesIgnoringSafeArea(.all)
                    
                    ScrollView(showsIndicators: false) { // Enable vertical scrolling
                        VStack(spacing: 10) { // Add some spacing between sections
                            
                            WeatherInfoSection(viewModel: viewModel)
                                .padding(.top, 10)
                                .padding(.horizontal, 10)
                            
                            ForecastView(viewModel: viewModel)
                            
                            DaysForecastView(viewModel: viewModel)
                        }
                        .padding(.bottom, 10)
                    }
                }
                .navigationTitle("Weather forecast") // Dynamically set title
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 10) {
                            Button(action: {
                                isSearchPresented.toggle()
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.subheadline) // Adjust size
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                isCityListPresented.toggle()
                            }) {
                                Image(systemName: "list.bullet")
                                    .font(.subheadline) // Adjust size
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .sheet(isPresented: $isCityListPresented) {
                    CityListView(viewModel: viewModel, isPresented: $isCityListPresented)
                }
                .sheet(isPresented: $isSearchPresented) {
                    LocationSearchView(viewModel: viewModel, locationManager: locationManager, isPresented: $isSearchPresented, selectedCity: $selectedCity)
                }
                .onChange(of: selectedCity) { city in
                    if !city.isEmpty {
                        viewModel.fetchWeather(for: city)
                        LocationStorage().saveLastCity(city)
                    }
                }
                .onChange(of: locationManager.city) { city in
                    if !city.isEmpty {
                        selectedCity = city
                        viewModel.fetchWeather(for: city)
                    }
                }
                .onChange(of: locationManager.city) { city in
                    if !city.isEmpty {
                        viewModel.updateCityName(from: locationManager)
                    }
                }
                .onChange(of: viewModel.cityName) { _ in
                    viewModel.updateCityName(from: locationManager)
                }
                .onAppear(perform: handleOnAppear)
            }
        }
    }
    
    private func handleOnAppear() {
        if let lastCity = LocationStorage().getLastCity(), !lastCity.isEmpty {
            selectedCity = lastCity
            viewModel.fetchWeather(for: lastCity)
        } else {
            locationManager.requestLocationPermission()
        }
    }
}

// Adjusted Preview Setup
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeatherView()
                .preferredColorScheme(.light)
                .previewDevice("iPhone 14 Pro")
            
            WeatherView()
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 14 Pro")
        }
    }
}
