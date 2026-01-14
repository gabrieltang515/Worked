//
//  WorkoutTypeSetting.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 19/7/24.
//

import Foundation
import SwiftUI

struct WorkoutTypeSetting: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var workoutTypes: [String]
    @Binding var suggestedWorkoutTypes: [String]
    var originalSuggestedWorkoutTypes: [String] // prewritten workout types basically
    @Binding var newCategory: String
    
    var disableField: Bool {
        newCategory.count < 3
    }
    
    var itemsKey = "itemsKey"
    var itemsKey2 = "itemsKey2"
    
    var body: some View {
        // Workout Types
            NavigationStack {
                Form {
                    // Categories
                    Section(header: Text("Current Categories"), footer: Text("Swipe left to delete category, drag and drop to reorder.").padding(.top, 5)) {
                        WorkoutTypeSettingPartOne(workoutTypes: $workoutTypes, suggestedWorkoutTypes: $suggestedWorkoutTypes, originalSuggestedWorkoutTypes: originalSuggestedWorkoutTypes)
                            .onAppear(perform: loadItems) // might be this causing the lag
                        
                    } // Section Bracket
                    
                    // Suggested Categories
                    Section(header: Text("Suggested Categories"), footer: Text("Ensure category names are at least 3 characters long.").padding(.top, 5)) {
                        WorkoutTypeSettingPartTwo(workoutTypes: $workoutTypes, suggestedWorkoutTypes: $suggestedWorkoutTypes, newCategory: $newCategory)
                    } // Section Bracket
                    
                } // Form Bracket


                .navigationBarTitleDisplayMode(.inline)
                
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Categories")
                    }
                }
                
            } // NavigationStack bracket
        
        
    } // Body var
        
    func loadItems() {
        if let savedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey) as? [String] {
            workoutTypes = savedWorkoutTypes
        }
            
        if let savedSuggestedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey2) as? [String] {
            suggestedWorkoutTypes = savedSuggestedWorkoutTypes
        }
    }
    
} // Struct
