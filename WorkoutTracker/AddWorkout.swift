import SwiftUI
import SwiftData
import Foundation
import CoreLocation
import CoreLocationUI
import MapKit
import UIKit

struct BeginningVisibleTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var scrollToBeginning: Bool
    let placeholder: String
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: BeginningVisibleTextField
        
        init(_ parent: BeginningVisibleTextField) {
            self.parent = parent
        }
        
        @objc func editingChanged(_ sender: UITextField) {
            // 1) Update the binding so SwiftUI knows about user typing
            parent.text = sender.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
    
    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.delegate = context.coordinator
        tf.placeholder = placeholder
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        
        // Whenever the user types, call `editingChanged(_:)`
        tf.addTarget(context.coordinator,
                     action: #selector(Coordinator.editingChanged(_:)),
                     for: .editingChanged)
        
        tf.returnKeyType = .done
        tf.textAlignment = .left
        tf.font = UIFont.preferredFont(forTextStyle: .body)
        tf.textColor = UIColor.label
        
        return tf
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        // 1) If SwiftUI's binding changed (programmatically or by user typing), update UITextField.text:
        if uiView.text != text {
            uiView.text = text
        }
        
        // 2) Only if the "scrollToBeginning" flag is true, force scroll offset back to zero:
        if scrollToBeginning {
            uiView.selectedTextRange = uiView.textRange(from: uiView.beginningOfDocument, to: uiView.beginningOfDocument)
            // Immediately reset the flag so that future user‐typing isn't forced back:
            DispatchQueue.main.async {
                self.scrollToBeginning = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

private struct LocationMarker: Identifiable {
    let coordinate: CLLocationCoordinate2D
    // use the lat/lon string as a stable ID
    var id: String { "\(coordinate.latitude),\(coordinate.longitude)" }
}

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // handle errors if desired
        print("Location error: \(error.localizedDescription)")
    }
}

struct MapPicker: View {
    @EnvironmentObject private var locationManager: LocationManager
    @Binding var coordinate: CLLocationCoordinate2D
    @Environment(\.dismiss) var dismiss
    @State private var region: MKCoordinateRegion
    
    // Variable to track what the user types in the searchBar
    @State private var searchQuery: String = ""
    @State private var suppressNextSearch: Bool = false
    
    // List of search results from Apple's query
    @State private var searchResults: [MKMapItem] = []
    
    // Boolean to track whether we are showing search results (list overlay)
    @State private var showingResults: Bool = false
    
    // Used to tell custom text field to scroll to beginning when necessary
    @State private var scrollToStart: Bool = false
    
    init(coordinate: Binding<CLLocationCoordinate2D>) {
        self._coordinate = coordinate
        let initial = coordinate.wrappedValue
        self._region = State(initialValue:
                                MKCoordinateRegion(
                                    center: initial,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
        )
    }
    
    private var mapLayer: some View {
        MapKitMapView(
            region: $region,
            selectedCoordinate: $coordinate
        )
        .ignoresSafeArea()
        .onChange(of: coordinate) { _, newCoord in
            region.center = newCoord
            
            let clLocation = CLLocation(
                latitude: newCoord.latitude,
                longitude: newCoord.longitude)
            
            CLGeocoder().reverseGeocodeLocation(clLocation, preferredLocale: nil) { placemarks, error in
                
                guard error == nil,
                      let first = placemarks?.first else
                {
                    DispatchQueue.main.async {
                        searchQuery = String(
                            format: "%.5f, %.5f",
                            newCoord.latitude,
                            newCoord.longitude
                        )
                        scrollToStart = true
                    }
                    
                    return
                }
                
                var parts: [String] = []
                
                if let name = first.name {
                    parts.append(name)
                } else if let street = first.thoroughfare {
                    parts.append(street)
                }
                
                
                if let subLocality = first.subLocality {
                    parts.append(subLocality)
                }
                
                if let city = first.locality {
                    parts.append(city)
                }
                
                if let postal = first.postalCode {
                    parts.append(postal)
                }
                
                if let country = first.country {
                    parts.append(country)
                }
                
                let addressString = parts.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    searchQuery = addressString
                }
                
                
            }
            
        }
        
    }
    
    private var searchBarLayer: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search for a place", text: $searchQuery, prompt: Text("e.g. Residential College 4"))
                    .foregroundStyle(.primary)
                    .onChange(of: searchQuery) {
                        if suppressNextSearch {
                            suppressNextSearch = false
                        } else {
                            performLocalSearch()
                        }
                    }
                    .onSubmit(of: .search) {
                        performLocalSearch()
                    }
                
                if !searchQuery.isEmpty {
                    Button {
                        // Clear the text when tapped
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    // Make the button tap area a little larger without pushing the textfield inset:
                    .padding(.trailing, 2)
                }
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial)              // system blur behind
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            .onChange(of: searchQuery) { _ in
                performLocalSearch()
            }
            
            
            Spacer()
        }
        .padding(.vertical, 8)
        .zIndex(1)
    }
    
    @ViewBuilder
    private var resultsList: some View {
        
        if showingResults {
            
            VStack(spacing: 0) {
                // Spacer pushes the list to start below the search bar
                Spacer().frame(height: safeTopPadding() + 60)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(searchResults, id: \.self) { item in
                            Button {
                                // Move the pin & map to this location
                                let placemark = item.placemark
                                let coord = placemark.coordinate
                                coordinate = coord
                                region.center = coord
                                
                                // Hide the results panel
                                withAnimation {
                                    showingResults = false
                                    suppressNextSearch = true
                                    var parts: [String] = []
                                    
                                    if let name = placemark.name {
                                        parts.append(name)
                                    } else if let street = placemark.thoroughfare {
                                        parts.append(street)
                                    }
                                    
                                    
                                    if let subLocality = placemark.subLocality {
                                        parts.append(subLocality)
                                    }
                                    
                                    if let city = placemark.locality {
                                        parts.append(city)
                                    }
                                    
                                    if let postal = placemark.postalCode {
                                        parts.append(postal)
                                    }
                                    
                                    if let country = placemark.country {
                                        parts.append(country)
                                    }
                                    
                                    let addressString = parts.joined(separator: ", ")
                                    
                                    searchQuery = addressString
                                    searchResults = []
                                    scrollToStart = true
                                }
                            } label: {
                                ResultRow(item: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider()
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                
                Spacer()
            }
            .zIndex(0)
            
        }
    }
    
    @ViewBuilder
    private var dimmedOverlay: some View {
        if showingResults {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tapping outside hides the results
                    withAnimation {
                        showingResults = false
                    }
                }
                .zIndex(0)
        }
    }
    
    private struct ResultRow: View {
        let item: MKMapItem
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name ?? "Unknown")
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                    Text(
                        [ item.placemark.locality,
                          item.placemark.administrativeArea,
                          item.placemark.country ]
                            .compactMap { $0 }
                            .joined(separator: ", ")
                    )
                    .font(.caption)
                    .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    private var resultsOverlay: some View {
        dimmedOverlay
        resultsList
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                mapLayer
                
                searchBarLayer
                
                resultsOverlay
                
                
                // Select location
                VStack {
                    Spacer()
                    Button("Select Location") {
                        dismiss()
                    }
                    .font(.headline)
                    .monospaced()
                    .foregroundStyle(.primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 24)
                    
                }
            }
            .onReceive(locationManager.$location.compactMap { $0 }) { loc in
              // Move the binding & map to the new user location
              coordinate = loc.coordinate
              region.center = loc.coordinate
            }
            
        }
        
        
    }
    
    private func performLocalSearch() {
        guard !searchQuery.isEmpty else {
            withAnimation {
                searchResults = []
                showingResults = false
            }
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        // Center the search on the map's current region
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil, let items = response?.mapItems else {
                return
            }
            DispatchQueue.main.async {
                self.searchResults = items
                withAnimation {
                    self.showingResults = true
                }
            }
        }
    }
    
    private func safeTopPadding() -> CGFloat {
        // 1) Find the first UIWindowScene in connectedScenes
        // 2) Cast it to UIWindowScene and get its windows array
        // 3) Locate the key window (or just pick the first one)
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        // 4) Read safeAreaInsets.top; if nil, fall back to 44
        return keyWindow?.safeAreaInsets.top ?? 44
    }
    
    
}

extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}

// To make CLLocationCoordinate Equatable
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (
        lhs: CLLocationCoordinate2D,
        rhs: CLLocationCoordinate2D
    ) -> Bool {
        lhs.latitude  == rhs.latitude &&
        lhs.longitude == rhs.longitude
    }
}

struct MapKitMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // long-press to drop a pin
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tap)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 1. keep the map's visible region in sync
        uiView.setRegion(region, animated: true)
        
        // 2. update the single annotation
        uiView.removeAnnotations(uiView.annotations)
        let pin = MKPointAnnotation()
        pin.coordinate = selectedCoordinate
        uiView.addAnnotation(pin)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitMapView
        
        init(_ parent: MapKitMapView) {
            self.parent = parent
            super.init()
        }
        
        // update the binding when the user scrolls/zooms
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async{
                self.parent.region = mapView.region
            }
        }
        
        // on long-press, drop a pin and update selectedCoordinate
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            
            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            parent.selectedCoordinate = coord
            parent.region.center = coord
        }
    }
}

struct WorkoutTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var workoutDescription: String
    var workoutType: String
    var location: String
    
    init(id: UUID = UUID(), workoutDescription: String, workoutType: String, location: String) {
        self.id = id
        self.workoutDescription = workoutDescription
        self.workoutType = workoutType
        self.location = location
    }
}

struct AddWorkout: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Receiving Variables
    var darkMode: Bool
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    var workoutTypes: [String]
    @Binding var showAdded: Bool
    let initialDate: Date
    
    // Internal Variables
    @State private var workoutDescription = ""
    @State private var workoutType = "Run"
    @State private var location = ""
    @State private var date: Date
    @FocusState private var descriptionIsFocused: Bool
    @FocusState private var locationIsFocused: Bool
    @State private var isKeyboardVisible = false
    
    // For location
    @StateObject private var locationManager = LocationManager()
    @State private var pickerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.35, longitude: 103.82)
    @State private var showingMapPicker = false
    
    // New: Segmented control state
    @State private var selectedMode: String = "New"
    let modes = ["New", "Templates"]
    
    // Remove local templates array and use @AppStorage for persistence
    @AppStorage("workoutTemplates") private var workoutTemplatesData: Data = Data()
    @State private var templates: [WorkoutTemplate] = []
    @State private var selectedTemplate: WorkoutTemplate?
    
    init(
        darkMode: Bool,
        selectedTab: Binding<String>,
        showingCompleted: Binding<Bool>,
        showingLapsed: Binding<Bool>,
        showingUpcoming: Binding<Bool>,
        workoutTypes: [String],
        showAdded: Binding<Bool>,
        initialDate: Date
    ) {
        self.darkMode = darkMode
        self._selectedTab = selectedTab
        self._showingCompleted = showingCompleted
        self._showingLapsed = showingLapsed
        self._showingUpcoming = showingUpcoming
        self.workoutTypes = workoutTypes
        self._showAdded = showAdded
        self.initialDate = initialDate
        self._date = State(initialValue: initialDate)
    }
    
    private func addWorkout() {
        let newWorkout = Workout(
            workoutDescription: (workoutDescription.isEmpty ? "No description" : workoutDescription),
            workoutType: workoutType,
            location: (location.isEmpty ? "Unknown location" : location),
            date: date,
            isCompleted: (date <= Date.now ? true : false),
            favourites: false
        )
        modelContext.insert(newWorkout)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save new workout:", error)
        }
        // adjustment of tab
        if date <= Date.now {
            selectedTab = "Completed"
            showingCompleted = true
            showingLapsed = false
            showingUpcoming = false
        } else {
            selectedTab = "Upcoming"
            showingCompleted = false
            showingLapsed = false
            showingUpcoming = true
        }
        dismiss()
        showAdded = true
    }
    
    private func useTemplate(_ template: WorkoutTemplate) {
        workoutDescription = template.workoutDescription
        workoutType = template.workoutType
        location = template.location
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(modes, id: \.self) { mode in
                            Text(mode)
                                .monospaced()
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal)
                .padding(.top, 16)
                
                Group {
                    if selectedMode == "New" {
                        Form {
                            Section {
                                Picker("Workout Type", selection: $workoutType) {
                                    ForEach(workoutTypes, id: \.self) {
                                        Text($0)
                                    }
                                }
                            }
                            Section("Workout Description") {
                                TextEditor(text: $workoutDescription)
                                    .frame(minHeight: 100)
                                    .padding(10)
                                    .border(Color.gray)
                                    .padding([.top, .bottom], 15)
                                    .focused($descriptionIsFocused)
                            }
                            Section("Location") {
                                HStack {
                                    TextField("Type location", text: $location)
                                        .focused($locationIsFocused)
                                    LocationButton {
                                        showingMapPicker = true
                                    }
                                    .labelStyle(.iconOnly)
                                    .symbolVariant(.fill)
                                    .tint(.accentColor)
                                    .foregroundStyle(.white)
                                    .font(.title2)
                                    .frame(width: 36, height: 36)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding(2)
                                }
                                if !location.isEmpty {
                                    Text("\(location)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                            }
                            Section("Date and Time") {
                                HStack {
                                    Spacer()
                                    DatePicker("Date and time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                        .labelsHidden()
                                        .padding(3)
                                    Spacer()
                                }
                            }
                            Section {
                                Button(action: addWorkout) {
                                    HStack(spacing: 8) {
                                        Text("Add")
                                            .font(.headline.monospaced())
                                            .foregroundColor(darkMode ? .white : .black)
                                        Image(darkMode ? "icons8-download-100-darkmode": "icons8-download-100-lightmode")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                            .padding(.bottom, 5)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 38)
                                }
                                .buttonStyle(.automatic)
                            }
                        } // Form Bracket
                    } else if selectedMode == "Templates" {
                        Form {
                            Section("Templates") {
                                ForEach(templates) { template in
                                    Button(action: {
                                        if selectedTemplate == template {
                                            selectedTemplate = nil
                                            workoutDescription = ""
                                            workoutType = "Run"
                                            location = ""
                                        } else {
                                            selectedTemplate = template
                                            useTemplate(template)
                                        }
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(template.workoutDescription)
                                                    .font(.headline)
                                                Text("Type: \(template.workoutType)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Text("Location: \(template.location)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            if selectedTemplate == template {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                    }
                                }
                            }
                            if selectedTemplate != nil {
                                Section("Workout Type") {
                                    Picker("Workout Type", selection: $workoutType) {
                                        ForEach(workoutTypes, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                }
                                Section("Workout Description") {
                                    TextEditor(text: $workoutDescription)
                                        .frame(minHeight: 100)
                                        .padding(10)
                                        .border(Color.gray)
                                        .padding([.top, .bottom], 15)
                                        .focused($descriptionIsFocused)
                                }
                                Section("Location") {
                                    HStack {
                                        TextField("Type location", text: $location)
                                            .focused($locationIsFocused)
                                        LocationButton {
                                            showingMapPicker = true
                                        }
                                        .labelStyle(.iconOnly)
                                        .symbolVariant(.fill)
                                        .tint(.accentColor)
                                        .foregroundStyle(.white)
                                        .font(.title2)
                                        .frame(width: 36, height: 36)
                                        .background(Color.secondary.opacity(0.1))
                                        .cornerRadius(12)
                                        .padding(2)
                                    }
                                    if !location.isEmpty {
                                        Text("\(location)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 4)
                                    }
                                }
                                Section("Date and Time") {
                                    HStack {
                                        Spacer()
                                        DatePicker("Date and time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                            .labelsHidden()
                                            .padding(3)
                                        Spacer()
                                    }
                                }
                                
                                
                                Section {
                                    Button(action: addWorkout) {
                                        HStack(spacing: 8) {
                                            Text("Add")
                                                .font(.headline.monospaced())
                                                .foregroundColor(darkMode ? .white : .black)
                                            Image(darkMode ? "icons8-download-100-darkmode": "icons8-download-100-lightmode")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 20, height: 20)
                                                .padding(.bottom, 5)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 38)
                                    }
                                    .buttonStyle(.automatic)
                                    .disabled(selectedTemplate == nil)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                if let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: workoutTemplatesData) {
                    templates = decoded
                }
            }
            .onChange(of: workoutTemplatesData) { newData in
                if let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: newData) {
                    templates = decoded
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        descriptionIsFocused = false
                        locationIsFocused = false
                    } label: {
                        Image(darkMode ? "icons8-keyboard-96-darkmode": "icons8-keyboard-96-lightmode")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .scaledToFit()
                    }
                    .foregroundStyle(.primary)
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(darkMode ? "icons8-close-outlined-darkmode": "icons8-close-outlined-lightmode" )
                            .resizable()
                            .frame(width: 28, height: 28)
                            .scaledToFit()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("Add Workout")
                        .font(.title3)
                        .padding()
                }
            } // toolbar bracket
            .sheet(isPresented: $showingMapPicker) {
                MapPicker(coordinate: $pickerCoordinate)
                    .environmentObject(locationManager)
                    .onAppear {
                        locationManager.requestLocation()
                    }
            }
            .onChange(of: pickerCoordinate) { oldCoord, newCoord in
                let clLocation = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude)
                CLGeocoder().reverseGeocodeLocation(clLocation, preferredLocale: nil) { placemarks, error in
                    guard error == nil,
                          let first = placemarks?.first
                    else {
                        DispatchQueue.main.async {
                            self.location = String(
                                format: "%.5f, %.5f",
                                newCoord.latitude,
                                newCoord.longitude
                            )
                        }
                        return
                    }
                    // Building a displayable address from the placemark field
                    var parts: [String] = []
                    if let name = first.name {
                        parts.append(name)
                    } else if let street = first.thoroughfare {
                        parts.append(street)
                    }
                    if let subLocality = first.subLocality {
                        parts.append(subLocality)
                    }
                    if let city = first.locality {
                        parts.append(city)
                    }
                    if let postal = first.postalCode {
                        parts.append(postal)
                    }
                    if let country = first.country {
                        parts.append(country)
                    }
                    let addressString = parts.joined(separator: ", ")
                    DispatchQueue.main.async {
                        self.location = addressString
                    }
                }
            }
        } // Navigation Stack Bracket
        .onAppear {
            // For map
            locationManager.requestLocation()
            if let loc = locationManager.location?.coordinate {
                pickerCoordinate = loc
            } else {
                // fallback to, say, Singapore
                pickerCoordinate = CLLocationCoordinate2D(latitude: 1.35, longitude: 103.82)
            }
        }
        .preferredColorScheme(darkMode ? .dark: .light)
    }
}



