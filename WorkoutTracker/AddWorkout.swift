import SwiftUI
import SwiftData
import Foundation
import CoreLocation
import CoreLocationUI
import MapKit
import UIKit


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
        print("Location error: \(error.localizedDescription)")
    }
}

// --- MapPicker and MapKitMapView refactor start ---

struct MapPicker: View {
    @EnvironmentObject private var locationManager: LocationManager
    @Binding var coordinate: CLLocationCoordinate2D
    @Environment(\.dismiss) var dismiss
    @State private var region: MKCoordinateRegion
    @State private var searchQuery: String = ""
    @State private var suppressNextSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    @State private var showingResults: Bool = false
    @State private var scrollToStart: Bool = false
    @State private var searchDebounceTimer: Timer? = nil
    @State private var hasCenteredOnUser: Bool = false
    @State private var isLoadingLocation: Bool = true
    @State private var locationError: String? = nil
    @State private var showSettingsAlert: Bool = false
    @State private var animatePanel: Bool = false

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
        .overlay(
            Group {
                if isLoadingLocation {
                    ZStack {
                        Color.black.opacity(0.2).ignoresSafeArea()
                        ProgressView("Locating...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(radius: 10)
                            .frame(maxWidth: 300)
                            .minimumScaleFactor(0.8)
                    }
                } else if let error = locationError {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        VStack(spacing: 16) {
                            Image(systemName: "location.slash")
                                .font(.title)
                                .foregroundColor(.red)
                            Text(error)
                                .multilineTextAlignment(.center)
                                .font(.headline)
                                .minimumScaleFactor(0.8)
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityLabel("Open Settings")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .frame(maxWidth: 340)
                    }
                }
            }, alignment: .center
        )
    }

    private var searchBarLayer: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.body)
                    TextField("Search for a place", text: $searchQuery, prompt: Text("e.g. Residential College 4").font(.body))
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .accessibilityLabel("Search for a place")
                        .onChange(of: searchQuery) {
                            if suppressNextSearch {
                                suppressNextSearch = false
                            } else {
                                searchDebounceTimer?.invalidate()
                                searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                    performLocalSearch()
                                }
                            }
                        }
                        .onSubmit(of: .search) {
                            searchDebounceTimer?.invalidate()
                            performLocalSearch()
                        }
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .accessibilityLabel("Clear search")
                        }
                        .padding(.trailing, 2)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 2)
                .padding(.leading, 8)
                .padding(.top, 10)
                .zIndex(10)
                .frame(maxWidth: .infinity)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .font(.title3.weight(.bold))
                        .accessibilityLabel("Close map")
                        .padding(10)
                        .background(Color(.systemBackground).opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(.leading, 4)
                .padding(.trailing, 8)
                .padding(.top, 10)
            }
        }
    }

    @ViewBuilder
    private var suggestionsPanel: some View {
        if showingResults && !searchResults.isEmpty {
            VStack(spacing: 0) {
                Spacer().frame(height: safeTopPadding() + 48)
                VStack(spacing: 0) {
                    ForEach(searchResults.prefix(5), id: \.self) { item in
                        Button {
                            let placemark = item.placemark
                            let coord = placemark.coordinate
                            coordinate = coord
                            region.center = coord
                            withAnimation {
                                showingResults = false
                                suppressNextSearch = true // <-- ensure next search is suppressed
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
                                searchResults = [] // Clear suggestions after picking
                                scrollToStart = true
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "Unknown")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .font(.body)
                                        .lineLimit(1)
                                    Text([
                                        item.placemark.locality,
                                        item.placemark.administrativeArea,
                                        item.placemark.country
                                    ].compactMap { $0 }.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .frame(height: 54) // Fixed height for each suggestion row
                        }
                        .buttonStyle(PlainButtonStyle())
                        if item != searchResults.prefix(5).last {
                            Divider()
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                .frame(maxHeight: 220)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            .zIndex(9)
            .animation(.easeInOut(duration: 0.25), value: showingResults)
        }
    }

    private var selectLocationButton: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Text("Select Location")
                        .font(.headline.monospaced())
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(coordinate.latitude == 0 && coordinate.longitude == 0 ? Color.gray : Color.accentColor)
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                        .minimumScaleFactor(0.8)
                }
                .disabled(coordinate.latitude == 0 && coordinate.longitude == 0)
                .opacity((coordinate.latitude == 0 && coordinate.longitude == 0) ? 0.6 : 1.0)
                .accessibilityLabel("Select Location")
                
                Button(action: {
                    isLoadingLocation = true
                    locationError = nil
                    if let userLoc = locationManager.location?.coordinate {
                        region.center = userLoc
                        coordinate = userLoc
                        hasCenteredOnUser = true
                        isLoadingLocation = false
                    } else {
                        locationManager.requestLocation()
                    }
                }) {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(minWidth: 36, maxWidth: 44, minHeight: 36, maxHeight: 44)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                        .accessibilityLabel("Go to my location")
                }
                .disabled(isLoadingLocation)
                .opacity(isLoadingLocation ? 0.6 : 1.0)
                Spacer()
            }
            .padding(.bottom, 20)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .zIndex(10)
    }

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
            searchBarLayer
            suggestionsPanel
            selectLocationButton
        }
        .onAppear {
            isLoadingLocation = true
            locationError = nil
            if let userLoc = locationManager.location?.coordinate {
                region.center = userLoc
                coordinate = userLoc
                hasCenteredOnUser = true
                isLoadingLocation = false
            } else {
                locationManager.requestLocation()
            }
        }
        .onReceive(locationManager.$location.compactMap { $0 }) { loc in
            if !hasCenteredOnUser {
                coordinate = loc.coordinate
                region.center = loc.coordinate
                hasCenteredOnUser = true
                isLoadingLocation = false
            }
        }
        .onChange(of: locationManager.location) { _, newLoc in
            if newLoc == nil {
                isLoadingLocation = false
                locationError = "Unable to access your location. Please check permissions."
            }
        }
        .onChange(of: searchQuery) { oldValue, newValue in
            // Only perform search if user actually changed the query
            if !suppressNextSearch {
                performLocalSearch()
            } else {
                suppressNextSearch = false
            }
        }
        .alert(isPresented: $showSettingsAlert) {
            Alert(
                title: Text("Location Permission Denied"),
                message: Text("Please enable location access in Settings to use this feature."),
                dismissButton: .default(Text("OK"))
            )
        }
        // --- New: Update search bar when coordinate changes ---
        .onChange(of: coordinate) { oldCoord, newCoord in
            let clLocation = CLLocation(latitude: newCoord.latitude, longitude: newCoord.longitude)
            CLGeocoder().reverseGeocodeLocation(clLocation, preferredLocale: nil) { placemarks, error in
                guard error == nil,
                      let first = placemarks?.first
                else {
                    DispatchQueue.main.async {
                        self.suppressNextSearch = true
                        self.searchQuery = String(
                            format: "%.5f, %.5f",
                            newCoord.latitude,
                            newCoord.longitude
                        )
                        self.showingResults = false // Hide suggestions after pin move
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
                    self.suppressNextSearch = true
                    self.searchQuery = addressString
                    self.showingResults = false // Hide suggestions after pin move
                }
            }
        }
    }

    private func performLocalSearch() {
        // --- Rate limiting: allow max 50 searches per 60 seconds (sliding window) ---
        struct RateLimiter {
            static var searchTimestamps: [Date] = []
            static let maxRequests = 50
            static let window: TimeInterval = 60.0
            static func canPerformSearch() -> Bool {
                let now = Date()
                // Remove timestamps older than 60 seconds
                searchTimestamps = searchTimestamps.filter { now.timeIntervalSince($0) < window }
                if searchTimestamps.count < maxRequests {
                    searchTimestamps.append(now)
                    return true
                } else {
                    return false
                }
            }
        }
        guard !searchQuery.isEmpty else {
            withAnimation {
                searchResults = []
                showingResults = false
            }
            return
        }
        if suppressNextSearch {
            suppressNextSearch = false
            // Do not show suggestions if suppressNextSearch is true
            return
        }
        // --- Check rate limit ---
        guard RateLimiter.canPerformSearch() else {
            // Optionally, you could show a message to the user here
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil, let items = response?.mapItems else {
                return
            }
            DispatchQueue.main.async {
                self.searchResults = items
                // Only show suggestions if not suppressed
                if !self.suppressNextSearch {
                    withAnimation {
                        self.showingResults = true
                    }
                } else {
                    self.showingResults = false
                }
            }
        }
    }

    private func safeTopPadding() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return keyWindow?.safeAreaInsets.top ?? 44
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
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tap)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
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
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async{
                self.parent.region = mapView.region
            }
        }
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            parent.selectedCoordinate = coord
            parent.region.center = coord
        }
        // Custom pin view for selected location
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil // Use default blue dot
            }
            let identifier = "SelectedPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.markerTintColor = UIColor.systemOrange
                annotationView?.glyphImage = UIImage(systemName: "mappin")
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
    }
}
// --- MapPicker and MapKitMapView refactor end ---

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
    var isTemplateMode: Bool = false
    
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
        initialDate: Date,
        isTemplateMode: Bool = false
    ) {
        self.darkMode = darkMode
        self._selectedTab = selectedTab
        self._showingCompleted = showingCompleted
        self._showingLapsed = showingLapsed
        self._showingUpcoming = showingUpcoming
        self.workoutTypes = workoutTypes
        self._showAdded = showAdded
        self.initialDate = initialDate
        self.isTemplateMode = isTemplateMode
        self._date = State(initialValue: initialDate)
    }
    
    private func addWorkout() {
        if isTemplateMode {
            // Create a template instead of a workout
            let newTemplate = WorkoutTemplate(
                workoutDescription: (workoutDescription.isEmpty ? "No description" : workoutDescription),
                workoutType: workoutType,
                location: (location.isEmpty ? "Unknown location" : location)
            )
            
            // Add to templates array
            templates.append(newTemplate)
            
            // Save to @AppStorage
            if let encoded = try? JSONEncoder().encode(templates) {
                workoutTemplatesData = encoded
            }
            
            dismiss()
        } else {

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
    }
    
    private func useTemplate(_ template: WorkoutTemplate) {
        workoutDescription = template.workoutDescription
        workoutType = template.workoutType
        location = template.location
    }
    
    // MARK: - Subviews to break up large expressions
    
    @ViewBuilder
    private func workoutTypeSection() -> some View {
        Section {
            Picker("Workout Type", selection: $workoutType) {
                ForEach(workoutTypes, id: \.self) {
                    Text($0)
                }
            }
        }
    }
    
    @ViewBuilder
    private func workoutDescriptionSection() -> some View {
        Section("Workout Description") {
            TextEditor(text: $workoutDescription)
                .frame(minHeight: 100)
                .padding(10)
                .border(Color.gray)
                .padding([.top, .bottom], 15)
                .focused($descriptionIsFocused)
        }
    }
    
    @ViewBuilder
    private func locationSection() -> some View {
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
            if location.count > 25 {
                HStack {
                    Text("\(location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    Spacer()
                    Button(action: { location = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
        }
    }
    
    @ViewBuilder
    private func dateSection() -> some View {
        Section("Date and Time") {
            HStack {
                Spacer()
                DatePicker("Date and time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .padding(3)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func addButtonSection(isTemplate: Bool = false, disable: Bool = false) -> some View {
        Section {
            Button(action: addWorkout) {
                HStack(spacing: 8) {
                    Text(isTemplate ? "Add Template" : "Add")
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
            .disabled(disable)
        }
    }
    
    @ViewBuilder
    private func templatesSection() -> some View {
        Section("Templates") {
            if templates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "dumbbell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.secondary)
                    Text("No templates found")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ForEach(selectedTemplate == nil ? templates : templates.filter { $0 == selectedTemplate }) { template in
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
                                    .foregroundStyle(darkMode ? .white : .black)
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
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if !isTemplateMode {
                    HStack {
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(modes, id: \.self) { mode in
                                Text(mode)
                                    .monospaced()
                            }
                        }
                        .pickerStyle(.segmented)
                        .onAppear {
                            let fontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
                            let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
                            let boldFont = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)
                            UISegmentedControl.appearance().setTitleTextAttributes([
                                .font: font
                            ], for: .normal)
                            UISegmentedControl.appearance().setTitleTextAttributes([
                                .font: boldFont
                            ], for: .selected)
                        }
                    }
                    .frame(maxWidth: 500)
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                Group {
                    if isTemplateMode || selectedMode == "New" {
                        Form {
                            workoutTypeSection()
                            workoutDescriptionSection()
                            locationSection()
                            if !isTemplateMode {
                                dateSection()
                            }
                            addButtonSection(isTemplate: isTemplateMode)
                        }
                    } else if selectedMode == "Templates" {
                        Form {
                            templatesSection()
                            if selectedTemplate != nil {
                                workoutTypeSection()
                                workoutDescriptionSection()
                                locationSection()
                                dateSection()
                                addButtonSection(disable: selectedTemplate == nil)
                            }
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: workoutTemplatesData) {
                        DispatchQueue.main.async {
                            templates = decoded
                        }
                    }
                }
            }
            .onChange(of: workoutTemplatesData) { _oldData, newData in
                DispatchQueue.global(qos: .userInitiated).async {
                    if let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: newData) {
                        DispatchQueue.main.async {
                            templates = decoded
                        }
                    }
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
                    Text(isTemplateMode ? "Add Template" : "Add Workout")
                        .font(.title3)
                        .padding()
                }
            } // toolbar bracket
            .sheet(isPresented: $showingMapPicker) {
                MapPicker(coordinate: $pickerCoordinate)
                    .environmentObject(locationManager)
                    .onAppear {
                        locationManager.requestLocation()
                        if let loc = locationManager.location?.coordinate {
                            pickerCoordinate = loc
                        }
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
            // Only set pickerCoordinate default, don't request location yet
            pickerCoordinate = CLLocationCoordinate2D(latitude: 1.35, longitude: 103.82)
        }
        .preferredColorScheme(darkMode ? .dark: .light)
    }
}

// MARK: - Equatable conformance for CLLocationCoordinate2D
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}



