
import Foundation
import SwiftUI


struct WorkoutTypeSettingPartOne: View {
    @Binding var workoutTypes: [String]
    @Binding var suggestedWorkoutTypes: [String]
    var originalSuggestedWorkoutTypes: [String]
    
    var itemsKey = "itemsKey"
    var itemsKey2 = "itemsKey2"
    
    var body: some View {
        List {
            ForEach($workoutTypes, id: \.self /*,editActions: .all*/) { $workoutType in
                HStack {
                    Text(workoutType)
                    Spacer()
                    Image("icons8-grip-lines-96")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                } // HStack Bracket
                .contentShape(Rectangle())
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive ) {
                        if let index = workoutTypes.firstIndex(of: workoutType) {
                            deleteWorkoutTypeTwo(at: index)
                        }
                    } label: {
                        Label("delete", systemImage: "trash.fill")
                    }
                }
                
            } // For Each
          .onMove(perform: move)
        
            
        } // List Bracket
    }
    
    func deleteWorkoutTypeTwo(at Index: Int) {
        workoutTypes.remove(at: Index)
        for workoutType in originalSuggestedWorkoutTypes {
            if workoutTypes.contains(workoutType) == false && suggestedWorkoutTypes.contains(workoutType) == false {
                withAnimation {
                    prepend(workoutType)
                }
            }
            saveItems()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        workoutTypes.move(fromOffsets: source, toOffset: destination)
        saveItems()
    }
    
    func prepend(_ workoutType: String) {
        suggestedWorkoutTypes.insert(workoutType, at: 0)
    }
    
    func saveItems() {
        UserDefaults.standard.set(workoutTypes, forKey: itemsKey)
        UserDefaults.standard.set(suggestedWorkoutTypes, forKey: itemsKey2)
    }
    
    
}
