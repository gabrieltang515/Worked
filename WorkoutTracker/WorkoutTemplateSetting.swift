import SwiftUI
import CoreLocation
import CoreLocationUI
import MapKit

struct WorkoutTemplateSetting: View {
    @Binding var templates: [WorkoutTemplate]
    let darkMode: Bool
    @Binding var workoutTypes: [String]
    @Binding var showBottombar: Bool
    @State private var showingAddWorkout: Bool = false
    @State private var selectedTab: String = "Settings"
    @State private var showingCompleted: Bool = false
    @State private var showingLapsed: Bool = false
    @State private var showingUpcoming: Bool = false
    @State private var showAdded: Bool = false
    
    // Add @AppStorage to sync with the actual stored data
    @AppStorage("workoutTemplates") private var workoutTemplatesData: Data = Data()
    
    @State private var showingDeleteTemplateAlert = false
    @State private var templatePendingDelete: WorkoutTemplate? = nil
    
    var body: some View {
        navigationForm
          .fullScreenCover(isPresented: $showingAddWorkout,        content: addTemplateCover)
          .toolbar { toolbarItems }
          .navigationBarTitleDisplayMode(.inline)
          .onAppear(perform: loadFromStorage)
          .onChange(of: workoutTemplatesData) { oldData, newData in loadFromStorage() }
          .onChange(of: templates)             { saveToStorage() }
          .alert("Delete Template", isPresented: $showingDeleteTemplateAlert) {
              Button("Delete", role: .destructive) {
                  if let toDelete = templatePendingDelete,
                     let idx = templates.firstIndex(of: toDelete) {
                    templates.remove(at: idx)
                  }
                  templatePendingDelete = nil
              }
              Button("Cancel", role: .cancel) {
                  templatePendingDelete = nil
              }
          } message: {
              Text("Are you sure you want to delete this template permanently?")
          }
      }

      // this is the core Form + List / empty-state
      @ViewBuilder
      private var navigationForm: some View {
        NavigationStack {
          Form {
            if templates.isEmpty {
              emptyStateView
            } else {
              templatesListView
            }
          }
        }
      }

      private var emptyStateView: some View {
        VStack(spacing: 12) {
          Image(systemName: "dumbbell")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundStyle(.secondary)
          Text("No templates found")
            .font(.headline)
          Button(action: { showingAddWorkout = true }) {
            Label("Add a template", systemImage: "plus.app")
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
      }

      private var templatesListView: some View {
        Section("Current Templates") {
          List {
            ForEach(templates) { template in
              NavigationLink(destination: EditWorkoutTemplateView(
                template: binding(for: template),
                onSave: { updated in
                  if let idx = templates.firstIndex(of: template) {
                    templates[idx] = updated
                  }
                },
                darkMode: darkMode,
                workoutTypes: workoutTypes,
                showBottombar: $showBottombar
              )) {
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
                }
              }
              .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                  templatePendingDelete = template
                  showingDeleteTemplateAlert = true
                } label: {
                    Image("icons8-delete-darkmode")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .scaledToFit()
                        .tint(.red)
                }
              }
            }
          }
        }
      }

    @ToolbarContentBuilder
      private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
          Text("Templates")
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: { showingAddWorkout = true }) {
            Image(darkMode ? "icons8-add-v3-100-darkmode"
                           : "icons8-add-v3-100-lightmode")
              .resizable()
              .frame(width: 28, height: 28)
              .scaledToFit()
          }
          .monospaced()
        }
      }

      private func addTemplateCover() -> some View {
        AddWorkout(
          darkMode: darkMode,
          selectedTab: .constant("Settings"),
          showingCompleted: .constant(false),
          showingLapsed:   .constant(false),
          showingUpcoming:.constant(false),
          workoutTypes: workoutTypes,
          showAdded: .constant(false),
          initialDate: .now,
          isTemplateMode: true
        )
        .eraseToAnyView()
      }
    
      private func loadFromStorage() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: workoutTemplatesData) {
                DispatchQueue.main.async {
                    templates = decoded
                }
            }
        }
      }

      private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(templates) {
          workoutTemplatesData = encoded
        }
      }

    // Helper to get a binding for a template in the array
    private func binding(for template: WorkoutTemplate) -> Binding<WorkoutTemplate> {
        guard let idx = templates.firstIndex(of: template) else {
            // fallback to a dummy binding
            return .constant(template)
        }
        return $templates[idx]
    }
}

private extension View {
  func eraseToAnyView() -> AnyView { AnyView(self) }
}

struct EditWorkoutTemplateView: View {
    @Binding var template: WorkoutTemplate
    var onSave: (WorkoutTemplate) -> Void
    let darkMode: Bool
    var workoutTypes: [String]
    @Binding var showBottombar: Bool

    @State private var workoutDescription: String = ""
    @State private var workoutType: String = "Run"
    @State private var location: String = ""
    @FocusState private var locationIsFocused: Bool
    @StateObject private var locationManager = LocationManager()
    @State private var pickerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.35, longitude: 103.82)
    @State private var showingMapPicker = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
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
                        .font(.title2)
                        .frame(width: 36, height: 36)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(2)
                    }
                    if location.count > 25 {
                        Text("\(location)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                Section {
                    Button {
                        template.workoutDescription = workoutDescription
                        template.workoutType = workoutType
                        template.location = location
                        onSave(template)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Save Template")
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

                }
            }
            .onAppear {
                workoutDescription = template.workoutDescription
                workoutType = template.workoutType
                location = template.location
                locationManager.requestLocation()
                if let loc = locationManager.location?.coordinate {
                    pickerCoordinate = loc
                } else {
                    pickerCoordinate = CLLocationCoordinate2D(latitude: 1.35, longitude: 103.82)
                }
                showBottombar = false
            }
            .onDisappear {
                showBottombar = true
            }
            .sheet(isPresented: $showingMapPicker) {
                MapPicker(coordinate: $pickerCoordinate, selectedAddress: $location)
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Template")
                        .monospaced()
                }
            }
        }
        .preferredColorScheme(darkMode ? .dark: .light)
    }
} 
