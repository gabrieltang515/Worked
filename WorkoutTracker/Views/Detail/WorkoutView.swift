import SwiftUI
import SwiftData
import CoreLocation
import CoreLocationUI
import MapKit
import UIKit

struct WorkoutView: View {
    // External Properties
    @Bindable var workout: Workout
    var workoutTypes: [String]
    var darkMode: Bool
    var selectedTab: String
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    
    // to show "zeng" alerts when a workout is deleted/mark as complete (or incomplete) / when duplicated (coming soon)
    @Binding var showDeleted: Bool
    @Binding var showCompleted: Bool // Remove this if not used elsewhere
    @Binding var showIncomplete: Bool // Remove this if not used elsewhere
    
    // Internal Properties
    // Edit mode and alerts
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingCompletedAlert = false
    @State private var showingIncompleteAlert = false
    
    // For Keyboard Focus
    @FocusState private var descriptionIsFocused: Bool
    @FocusState private var locationIsFocused: Bool
    
    // For location functionality (from AddWorkout)
    @StateObject private var locationManager = LocationManager()
    @State private var pickerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.35, longitude: 103.82)
    @State private var showingMapPicker = false
    
    var body: some View {
        NavigationStack {
            if editMode?.wrappedValue.isEditing == true {
                Form {
                    Picker("Workout Type", selection: $workout.workoutType) {
                        ForEach(workoutTypes, id: \.self) {
                            Text($0)
                        }
                    }

                    Section("Workout Description") {
                            TextEditor(text: $workout.workoutDescription)
                                .frame(minHeight: 100)
                                .padding(10)
                                .border(Color.gray)
                                .padding([.top, .bottom], 15)
                                .focused($descriptionIsFocused)
                    }


                    Section("Location") {
                        HStack {
                            TextField("Type location", text: $workout.location)
                                .focused($locationIsFocused)
                            
                            Button(action: {
                                showingMapPicker = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                        .frame(width: 36, height: 36)

                                    Image(systemName: "location.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .shadow(radius: 2)
                            .padding(2)
                            .accessibilityLabel("Open Map Picker")

                        }
                        
                        if workout.location.count > 25 {
                            Text("\(workout.location)")
                                .font(.subheadline)                                
                                .foregroundColor(.secondary)
                                .padding(.top, 4)   
                        }
                    }
                    Section("Date and Time") {
                        HStack {
                            Spacer()
                            DatePicker("Date and time", selection: $workout.date, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .padding(3)
                            Spacer()
                        }
                    }
                
                } // Form Bracket
                .preferredColorScheme(darkMode ? .dark : .light)
                .scrollBounceBehavior(.basedOnSize)
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
                        
                        EditButton()
                    }
                }
                .sheet(isPresented: $showingMapPicker) {
                    MapPicker(coordinate: $pickerCoordinate, selectedAddress: $workout.location)
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
                                self.workout.location = String(
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
                            self.workout.location = addressString
                        }
                    }
                }
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
                .onChange(of: editMode?.wrappedValue) { oldValue, newValue in
                    if newValue == .inactive {
                        if workout.date <= Date.now {
                            workout.isCompleted = true
                        } else {
                            workout.isCompleted = false
                        }
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save workout changes: \(error)")
                        }
                    }
                }
                
            } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(workout.workoutType)
                                .frame(width: 368, alignment: .center)
                                .padding([.horizontal, .bottom])
                                .font(.title.bold().monospaced())
                            
                            Text("Workout Description")
                                .font(.title3/*.italic()*/.monospaced())
                                .padding([.horizontal, .top])
                            
                            Text(workout.workoutDescription)
                                .font(.system(size: 18).monospaced())
                                .foregroundStyle(.secondary) // or use secondary colour
                                .padding(15)
                                .frame(width: 368)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .overlay (
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.2)
                                    )
                                .padding(.horizontal)

                                    
                            Text("\(workout.location), \(workout.formattedDate)")
                                .foregroundStyle(.secondary)
                                .padding()
                                .font(.subheadline.monospaced())

                        }
                    }
                    .preferredColorScheme(darkMode ? .dark : .light)
                    .scrollBounceBehavior(.basedOnSize)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                // Edit button, Duplicate button, Delete button, Mark as completed button (if under lapsed) should be created here
                                // Maybe change the system images to icons8 images
                                Button {
                                    isEditing.toggle()
                                    editMode?.wrappedValue = .active
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                
                                Button("Duplicate workout", systemImage: "doc.on.doc", action: duplicateWorkout)
                                
                                // insert alert for workout deletion
                                Button("Delete workout", systemImage: "trash") {
                                    showingDeleteAlert = true
                                }
                                
                                // Only show mark as complete/incomplete in Completed and Lapsed tabs.
                                if selectedTab == "Completed" || selectedTab == "Lapsed" {
                                    Button(selectedTab == "Completed" ? "Mark as Incomplete": "Mark as Completed", systemImage: selectedTab == "Completed" ? "bookmark.slash" : "bookmark") {
                                        selectedTab == "Completed" ? showingIncompleteAlert.toggle() : showingCompletedAlert.toggle()
//                                        workout.isCompleted.toggle()
//                                        dismiss()
                                    }
                                }

                            } label: {
                                Image(darkMode ? "icons8-dots-100-darkmode": "icons8-dots-100-lightmode")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .scaledToFit()
                            } // Menu bracket
                        } // toolbar item bracket

                        
                    }
                
                    .onChange(of: editMode?.wrappedValue, initial: true) {
                        isEditing = false
                    }
                
                    .alert("Delete Workout", isPresented: $showingDeleteAlert) {
                        Button("Delete", role: .destructive, action: deleteWorkout)
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete this workout permanently?")
                    }
                
                    .alert("Mark as Completed", isPresented: $showingCompletedAlert) {
                        Button("Mark as Completed", action: {
                            workout.isCompleted = true
//                            showCompleted.toggle()
                            dismiss()
                        })
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Mark this workout as Completed?")
                    }
                
                    .alert("Mark as Incomplete", isPresented: $showingIncompleteAlert) {
                        Button("Mark as Incomplete", action: {
                            workout.isCompleted = false
//                            showIncomplete.toggle()
                            dismiss()
                        })
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Mark this workout as Incomplete?")
                    }
                
                    .animation(.easeInOut(duration: 3.0), value: isEditing)
                
            } // "else" bracket
        } // Navigation Stack bracket
        
    } // Body Bracket
    
    func duplicateWorkout() {
        let newWorkout = Workout(workoutDescription: (workout.workoutDescription.isEmpty ? "No description" : workout.workoutDescription), workoutType: workout.workoutType, location: (workout.location.isEmpty ? "Unknown location" : workout.location), date: workout.date, isCompleted: (workout.date <= Date.now ? true : false), favourites: workout.favourites )
        modelContext.insert(newWorkout)
        dismiss()
    }
    
    func deleteWorkout() {
        modelContext.delete(workout)
        dismiss()
    }
    
} 


