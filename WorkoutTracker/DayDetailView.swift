import Foundation
import SwiftUI
import SwiftData

struct DayDetailView: View {
    let date: Date
    let workoutsForDay: [Workout]
    @Environment(\.dismiss) var dismiss
    
    // From parent
    var darkMode: Bool
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    var workoutTypes: [String]
    
    @Binding var showingDetail: Bool
    
    // For aesthetic. Optional to work with
    @Binding var showAdded: Bool
    @Binding var showDeleted: Bool
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    
    @State private var showAddWorkoutSheet = false
    
    var body: some View {
        // Listing the workouts if they exist.
        List {
            ForEach(workoutsForDay) { workout in
                NavigationLink(destination: WorkoutView(workout: workout, workoutTypes: workoutTypes, darkMode: darkMode, selectedTab: selectedTab, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)) {
                    
                    HStack(alignment: .firstTextBaseline, spacing: 15) {
                        Text(workout.workoutType)
                            .font(.headline)
                            .monospaced()
                        
                        Text(workout.workoutDescription)
                            .foregroundStyle(.secondary)
                            .font(.subheadline.monospaced())

                    }
                    .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .leading)
                }
            }
        }
        .fullScreenCover(isPresented: $showAddWorkoutSheet) {
            AddWorkout(darkMode: darkMode, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showAdded: $showAdded, initialDate: date)
        }

        
    } // End of view
}

