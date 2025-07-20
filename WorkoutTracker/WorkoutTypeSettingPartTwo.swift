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
                        }
                }
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
                
                
            }
        }
        
    }
    
    
    
    func saveItems() {
        UserDefaults.standard.set(workoutTypes, forKey: itemsKey)
        UserDefaults.standard.set(suggestedWorkoutTypes, forKey: itemsKey2)
    }
    
}
