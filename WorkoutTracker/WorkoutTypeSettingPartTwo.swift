//
//  WorkoutTypeSettingPartTwo.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 20/7/24.
//

import Foundation
import SwiftUI

struct WorkoutTypeSettingPartTwo: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var workoutTypes: [String]
    @Binding var suggestedWorkoutTypes: [String]
    
    @Binding var newCategory: String
    
    var disableField: Bool {
        newCategory.count < 3
    }

    
    var itemsKey = "itemsKey"
    var itemsKey2 = "itemsKey2"
    
    var body: some View {
        List {
            ForEach(suggestedWorkoutTypes, id: \.self) { suggestedWorkoutType in
                HStack {
                    Text(suggestedWorkoutType)
                    Spacer()
                    Image(systemName: "plus")
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            withAnimation {
                                workoutTypes.append(suggestedWorkoutType)
                                if let index = suggestedWorkoutTypes.firstIndex(of: suggestedWorkoutType) {
                                    suggestedWorkoutTypes.remove(at: index)
                                }
                            }
                            saveItems()
                        } // on tap Gesture
                } // HStack Bracket
                .contentShape(Rectangle())
                
            } // ForEach Bracket
            
            HStack {
                TextField("New Category", text: $newCategory)
                    .onSubmit {
                        dismiss()
                    }
                Spacer()
                Image(systemName: "plus")
                    .foregroundStyle(.secondary)
                    .onTapGesture {
                        withAnimation {
                            workoutTypes.append(newCategory)
                            newCategory = ""
                        }
                        saveItems()
                    }
                    .disabled(disableField)
                
                
            } // HStack Bracket
            
        } // Inner List Bracket
        // ADD FOCUS THINGY HERE for keyboard
        
        
    }
    
    
    
    func saveItems() {
        UserDefaults.standard.set(workoutTypes, forKey: itemsKey)
        UserDefaults.standard.set(suggestedWorkoutTypes, forKey: itemsKey2)
    }
    
}
