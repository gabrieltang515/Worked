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
    var originalSuggestedWorkoutTypes: [String] // all prewritten workout types basically
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
                    Section(header: Text("Categories"), footer: Text("Swipe left to delete category, drag and drop to reorder.").padding(.top, 5)) {
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
                        Text("Workout Categories")
                    }
                }
                
            } // NavigationStack bracket
        
        
    } // Body var
    
//    func move(from source: IndexSet, to destination: Int) {
//        workoutTypes.move(fromOffsets: source, toOffset: destination)
//        saveItems()
//    }
    
    
    func loadItems() {
        if let savedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey) as? [String] {
            workoutTypes = savedWorkoutTypes
        }
            
        if let savedSuggestedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey2) as? [String] {
            suggestedWorkoutTypes = savedSuggestedWorkoutTypes
        }
    }
    
//    func saveItems() {
//        UserDefaults.standard.set(workoutTypes, forKey: itemsKey)
//        UserDefaults.standard.set(suggestedWorkoutTypes, forKey: itemsKey2)
//    }
    
//    func deleteWorkoutType(at offsets: IndexSet) {
//        workoutTypes.remove(atOffsets: offsets)
//        for workoutType in originalSuggestedWorkoutTypes {
//            if workoutTypes.contains(workoutType) == false && suggestedWorkoutTypes.contains(workoutType) == false {
//                suggestedWorkoutTypes.append(workoutType)
//            }
//        }
//        saveItems()
//    }
    
//    func deleteWorkoutTypeTwo(at Index: Int) {
//        workoutTypes.remove(at: Index)
//        for workoutType in originalSuggestedWorkoutTypes {
//            if workoutTypes.contains(workoutType) == false && suggestedWorkoutTypes.contains(workoutType) == false {
////                suggestedWorkoutTypes.append(workoutType)
//                withAnimation {
//                    prepend(workoutType)
//                }
//            }
//            saveItems()
//        }
//    }
    
//    func prepend(_ workoutType: String) {
//        suggestedWorkoutTypes.insert(workoutType, at: 0)
//    }
//    
    
} // Struct
