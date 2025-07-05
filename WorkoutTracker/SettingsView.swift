import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    
    // For Settings Bar (disappears when clicked in)
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    @Binding var showingCalendar: Bool
    @Binding var showingSettings: Bool
    
    // For Appearance
    @Binding var darkMode: Bool

    @State private var selectedMode = "System"
    
    // For Workout Types
    @Binding var workoutTypes: [String]
    @Binding var suggestedWorkoutTypes: [String]
    @State private var originalSuggestedWorkoutTypes = ["Run", "Walk", "Gym", "Swim", "Cycle", "Yoga", "Football", "Basketball", "Bouldering", "Pilates", "Spin", "Calisthenics"]
    @State private var newCategory = ""
    var disableField: Bool {
        newCategory.count < 3
    }
    
    // For Workout Templates
    @AppStorage("workoutTemplates") private var workoutTemplatesData: Data = Data()
    @State private var workoutTemplates: [WorkoutTemplate] = []
    
    var itemsKey = "itemsKey"
    var itemsKey2 = "itemsKey2"
    
    var body: some View {
        NavigationStack {
            Form {
                // General Settings Section
                Section("General") {
                    // Appearance
                    NavigationLink {
                        AppearanceSetting(darkMode: $darkMode, selectedMode: $selectedMode)
                    } label: {
                        Text("Appearance")
                    }
                    
                    // Workout Categories
                    NavigationLink {
                        WorkoutTypeSetting(workoutTypes: $workoutTypes, suggestedWorkoutTypes: $suggestedWorkoutTypes, originalSuggestedWorkoutTypes: originalSuggestedWorkoutTypes, newCategory: $newCategory)
                    } label: {
                        Text("Workout Categories")
                    }
                    
                    // Favourites
                    NavigationLink {
                        FavouritesSetting(selectedTab: selectedTab, workoutTypes: workoutTypes, darkMode: darkMode)
                    } label: {
                        Text("Favourites")
                    }

                    // Push Notifications
                    NavigationLink {
                        PushNotifications()
                    } label: {
                        Text("Push Notifications")
                    }
                    
                    // Lock with FaceID?
                    NavigationLink {
                        Text("Lock with FaceID")
                    } label: {
                        Text("Lock with FaceID")
                    }

                } // Section 1 Bracket
                
                // Workout Templates Section
                Section("Workout Templates") {
                    NavigationLink {
                        WorkoutTemplateSetting(templates: $workoutTemplates)
                    } label: {
                        Text("Manage Workout Templates")
                    }
                }
                
                // Data Section
                Section("Data") {
                    NavigationLink {
                        SyncToiCloud()
                    } label: {
                        Text("Sync to iCloud")
                    }
                    
                } // Section 2 Bracket
                
            } // Outmost Form Bracket
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.title)
                        .monospaced()
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
        
            
        } // Outmost Navigation Stack Bracket
        .preferredColorScheme(darkMode ? .dark: .light)
        .accentColor(darkMode ? .white: .black)
        .monospaced()
        
        BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        
        .onAppear {
            if let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: workoutTemplatesData) {
                workoutTemplates = decoded
            }
        }
        .onChange(of: workoutTemplates) { newTemplates in
            if let encoded = try? JSONEncoder().encode(newTemplates) {
                workoutTemplatesData = encoded
            }
        }
    } // Body Bracket
    
}// Settings View Struct Bracket



