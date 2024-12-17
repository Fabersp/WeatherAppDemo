//
//  LocationStorage.swift
//  WeatherApp
//
//  Created by Fabricio Padua on 11/4/24.
//

import Foundation

class LocationStorage {
    private let lastCityKey = "LastSearchedCity"

    func saveLastCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: lastCityKey)
    }

    func getLastCity() -> String? {
        return UserDefaults.standard.string(forKey: lastCityKey)
    }
}
