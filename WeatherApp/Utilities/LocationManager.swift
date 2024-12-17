import CoreLocation
import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    @Published var city: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var currentLocation: CLLocation? // Added to store the latest location
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = locationManager.authorizationStatus
    }

    /// Requests location permission from the user
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            print("Location permission denied or restricted. Please enable location services in settings.")
        @unknown default:
            print("Unknown authorization status.")
        }
    }

    // MARK: - CLLocationManagerDelegate Methods

    /// Called when the authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        case .notDetermined:
            print("Authorization not determined. Requesting permission...")
            locationManager.requestWhenInUseAuthorization()
        case .none:
            break
        @unknown default:
            print("Unknown authorization status encountered.")
        }
    }

    /// Called when the location manager successfully updates the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("No valid location data available.")
            return
        }
        
        // Store the latest location
        self.currentLocation = location

        // Reverse geocode to fetch the city name
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Failed to reverse geocode location: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found for location.")
                return
            }
            
            DispatchQueue.main.async {
                self?.city = placemark.locality ?? "Unknown City"
                print("City: \(self?.city ?? "Unknown City")")
            }
        }
    }

    /// Called when the location manager fails to retrieve a location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        
        // Handle specific errors (e.g., denied permission or location services disabled)
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("Location updates denied by user.")
            case .locationUnknown:
                print("The location is currently unknown.")
            case .network:
                print("Network error occurred while retrieving location.")
            default:
                print("CLError encountered: \(clError.localizedDescription)")
            }
        }
    }
}
