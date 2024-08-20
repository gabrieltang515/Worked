//
//  MapModel.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 9/7/24.
//


//
//import Foundation
//import MapKit
//
//struct Address: Codable {
//    let data: [Datum]
//}
//
//struct Datum: Codable {
//    let latitude, longitude: Double
//    let name: String?
//}
//
//struct Location: Identifiable {
//    let id = UUID()
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//}
//
//class MapAPI: ObservableObject {
//    private let BASE_URL = "http://api.positionstack.com/v1/forward"
//    private let API_KEY = "5ae574039986ae9d789ca917b00b20ca"
//    
//    @Published var region: MKCoordinateRegion
//    @Published var coordinates = []
//    @Published var locations: [Location] = []
//    
//    init() {
//        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.50, longitude: -0.1275 ), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
//        
//        self.locations.insert(Location(name: "Pin", coordinate: CLLocationCoordinate2D(latitude: 51.50, longitude: -0.1275)), at: 0)
//    }
//    
//    func getLocation(address: String, delta: Double) {
//        let pAddress = address.replacingOccurrences(of: " ", with: "%20")
//        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
//        
//        guard let url = URL(string: url_string) else {
//            print("Invalid URL")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else {
//                print(error!.localizedDescription)
//                return
//            }
//            
//            guard let newCoordinates = try? JSONDecoder().decode(Address.self, from: data) else { return }
//            
//            if newCoordinates.data.isEmpty {
//                print("Could not find the address...")
//                return
//            }
//            
//            DispatchQueue.main.async {
//                let details = newCoordinates.data[0]
//                let lat = details.latitude
//                let lon = details.longitude
//                let name = details.name
//                
//                self.coordinates = [lat, lon]
//                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.50, longitude: -0.1275 ), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
//                
//                let new_location = Location(name: name ?? "Pin", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
//                self.locations.removeAll()
//                self.locations.insert(new_location, at: 0)
//                
//                print("Successfully loaded the location")
//            }
//         }
//        .resume()
//    }
//    
//    
//}
