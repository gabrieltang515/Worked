//
//  SettingsView.swift
//  WorkoutTracker
//
//  Created by Rafael Soh on 2/5/24.
//

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
    
//    let modes = ["System", "Dark", "Light"]
    
    @State private var selectedMode = "System"
    
    // For Workout Types
    @Binding var workoutTypes: [String]
    @Binding var suggestedWorkoutTypes: [String]
    @State private var originalSuggestedWorkoutTypes = ["Run", "Walk", "Gym", "Swim", "Cycle", "Yoga", "Football", "Basketball", "Bouldering", "Pilates", "Spin", "Calisthenics"]
    @State private var newCategory = ""
    var disableField: Bool {
        newCategory.count < 3
    }
    
    var itemsKey = "itemsKey"
    var itemsKey2 = "itemsKey2"
    
    // For zeng? Required?
    
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

                    // Lock with FaceID?
                    
                    
                    
                    
                    
                } // Section 1 Bracket
                
                
                // Data Section
                Section("Data") {
                    NavigationLink {
                        Text("Coming Soon")
                            .font(.title2)
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
            
            BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode)
            
            
        } // Outmost Navigation Stack Bracket
        .preferredColorScheme(darkMode ? .dark: .light)
        .accentColor(darkMode ? .white: .black)
        .monospaced()
        
    } // Body Bracket
    
//    func move(from source: IndexSet, to destination: Int) {
//        workoutTypes.move(fromOffsets: source, toOffset: destination)
//        saveItems()
//    }
//    
//    func deleteWorkoutTypeTwo(at Index: Int) {
//        workoutTypes.remove(at: Index)
//        for workoutType in originalSuggestedWorkoutTypes {
//            if workoutTypes.contains(workoutType) == false && suggestedWorkoutTypes.contains(workoutType) == false {
//                suggestedWorkoutTypes.append(workoutType)
//            }
//            saveItems()
//        }
//    }
//        
//    func deleteWorkoutType(at offsets: IndexSet) {
//        workoutTypes.remove(atOffsets: offsets)
//        for workoutType in originalSuggestedWorkoutTypes {
//            if workoutTypes.contains(workoutType) == false && suggestedWorkoutTypes.contains(workoutType) == false {
//                suggestedWorkoutTypes.append(workoutType)
//            }
//        }
//        saveItems()
//    }
//        
//    func saveItems() {
//        UserDefaults.standard.set(workoutTypes, forKey: itemsKey)
//        UserDefaults.standard.set(suggestedWorkoutTypes, forKey: itemsKey2)
//    }
//        
//    func loadItems() {
//        if let savedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey) as? [String] {
//            workoutTypes = savedWorkoutTypes
//        }
//            
//        if let savedSuggestedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey2) as? [String] {
//            suggestedWorkoutTypes = savedSuggestedWorkoutTypes
//        }
//    }
    
}// Settings View Struct Bracket



