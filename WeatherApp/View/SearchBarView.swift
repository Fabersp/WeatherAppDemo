//
//  SearchBarView.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/5/24.
//
import SwiftUI
import MapKit

struct LocationSearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var locationManager: LocationManager // Add locationManager here
    
    @Binding var isPresented: Bool
    @Binding var selectedCity: String
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText, onCommit: searchForLocation)
                        .foregroundColor(Color.primary) // Adapts to light and dark mode
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6)) // Light gray background
                        .cornerRadius(10)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                
                HStack() {
                    Text("My Location")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        locationManager.requestLocationPermission()
                        viewModel.updateCityName(from: locationManager)
                        selectedCity = locationManager.city
                        viewModel.addCityToList(locationManager.city) // Add city to the list
                        viewModel.fetchWeather(for: locationManager.city) // Fetch weather
                        isPresented = false
                    }) {
                        Image(systemName: "location.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                
                // List of search results
                List(searchResults, id: \.self) { item in
                    Button(action: {
                        if let cityName = item.placemark.name {
                            selectedCity = cityName
                            viewModel.addCityToList(cityName) // Add city to the list
                            viewModel.fetchWeather(for: cityName) // Fetch weather for the selected city
                            isPresented = false // Close view
                        }
                    }) {
                        Text(item.placemark.name ?? "Unknown Location")
                            .foregroundColor(Color.primary)
                    }
                }
            }
            .navigationBarTitle("Search Location", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            }.foregroundColor(Color(.white)))
        }
        .onChange(of: searchText) { _ in
            searchForLocation()
        }
    }
    
    private func searchForLocation() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = [.address] // Search for cities and airports
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                searchResults = response.mapItems
            } else {
                searchResults = []
            }
        }
    }
}
