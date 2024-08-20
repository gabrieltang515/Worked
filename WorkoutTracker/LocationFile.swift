//
//  LocationFile.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 8/7/24.
//

//import Foundation
//import CoreLocation
//
//class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
//    @Published var userLocation: CLLocationCoordinate2D?
//    private var locationManager = CLLocationManager()
//    
//    override init() {
//        super.init()
//        self.locationManager.delegate = self
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.startUpdatingLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
////        guard let location = locations.last else {return}
////        userLocation = location.coordinate
//        manager.requestLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse || status == .authorizedAlways {
//            locationManager.startUpdatingLocation()
//        }
//    }
//}
