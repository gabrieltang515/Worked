import SwiftUI
import SwiftData
import Foundation

// Hex's of colours used in the app
// white is FFFFFF
// black is 000000
// gray is 808080
// padding at 20%

struct ContentView: View {
    @State private var selectedTab = "Completed"
    @State private var showingCompleted = true
    @State private var showingLapsed = false
    @State private var showingUpcoming = false
    @State private var showingCalendar = false
    @State private var showingSettings = false
    
    @State private var sortOrder = [
        SortDescriptor(\Workout.date, order: .reverse),
        SortDescriptor(\Workout.workoutType),
    ]
    
    // Filter Type Tracking
    
    @State private var filterTypeCompleted = "All"
    
    @State private var filterTypeLapsed = "All"
    
    @State private var filterTypeUpcoming = "All"
    
    @State var disabledEditButton: Bool = false
    
    // For full screen cover
    @State private var showingAddWorkout = false
    @State private var editingWorkout = false
    @State var workoutTypes = ["Run", "Walk", "Gym", "Swim", "Cycle", "Yoga"]
    @State var suggestedWorkoutTypes = ["Football", "Basketball", "Bouldering", "Pilates", "Spin", "Calisthenics"]
    
    var itemsKey = "itemsKey"
    var itemsKey2 = "itemsKey2"
     
    // For Settings Tab
    @Environment(\.colorScheme) var colorScheme
    @State private var darkMode = true
    
    // For adding, deleting, favouriting and completed alerts.
    @State private var showAdded = false
    @State private var animateAddedCircle = false
    
    @State private var showDeleted = false
    @State private var animateDeletedCircle = false
    
    @State private var showFavourited = false
    @State private var animatedFavouritedCircle = false
    
    @State private var showCompleted = false
    @State private var animateCompletedCircle = false
    
    @State private var showIncomplete = false
    @State private var animateIncompleteCircle = false
    
    // For Search bar
    @State private var searchQuery = ""

    var body: some View {
        switch selectedTab {
        case "Completed":
            CompletedView(
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                showingCalendar: $showingCalendar,
                showingSettings: $showingSettings,
                showingAddWorkout: $showingAddWorkout,
                editingWorkout: $editingWorkout,
                disabledEditButton: $disabledEditButton,
                searchQuery: $searchQuery,
                showAdded: $showAdded,
                showDeleted: $showDeleted,
                showCompleted: $showCompleted,
                showIncomplete: $showIncomplete,
                animateAddedCircle: $animateAddedCircle,
                animateDeletedCircle: $animateDeletedCircle,
                animateCompletedCircle: $animateCompletedCircle,
                animateIncompleteCircle: $animateIncompleteCircle,
                filterTypeCompleted: $filterTypeCompleted,
                sortOrder: $sortOrder,
                darkMode: darkMode,
                workoutTypes: workoutTypes,
                loadItems: loadItems
            )
            
        case "Lapsed":
            LapsedView(
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                showingCalendar: $showingCalendar,
                showingSettings: $showingSettings,
                showingAddWorkout: $showingAddWorkout,
                editingWorkout: $editingWorkout,
                disabledEditButton: $disabledEditButton,
                searchQuery: $searchQuery,
                showAdded: $showAdded,
                showDeleted: $showDeleted,
                showCompleted: $showCompleted,
                showIncomplete: $showIncomplete,
                animateAddedCircle: $animateAddedCircle,
                animateDeletedCircle: $animateDeletedCircle,
                animateCompletedCircle: $animateCompletedCircle,
                animateIncompleteCircle: $animateIncompleteCircle,
                filterTypeLapsed: $filterTypeLapsed,
                sortOrder: $sortOrder,
                darkMode: darkMode,
                workoutTypes: workoutTypes,
                loadItems: loadItems
            )
            
        case "Upcoming":
            UpcomingView(
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                showingCalendar: $showingCalendar,
                showingSettings: $showingSettings,
                showingAddWorkout: $showingAddWorkout,
                editingWorkout: $editingWorkout,
                disabledEditButton: $disabledEditButton,
                searchQuery: $searchQuery,
                showAdded: $showAdded,
                showDeleted: $showDeleted,
                showCompleted: $showCompleted,
                showIncomplete: $showIncomplete,
                animateAddedCircle: $animateAddedCircle,
                animateDeletedCircle: $animateDeletedCircle,
                animateCompletedCircle: $animateCompletedCircle,
                animateIncompleteCircle: $animateIncompleteCircle,
                filterTypeUpcoming: $filterTypeUpcoming,
                sortOrder: $sortOrder,
                darkMode: darkMode,
                workoutTypes: workoutTypes,
                loadItems: loadItems
            )
            .id(selectedTab) // Force refresh on tab switch
            
        case "Calendar":
            CalendarTabView(
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                showingCalendar: $showingCalendar,
                showingSettings: $showingSettings,
                showingAddWorkout: $showingAddWorkout,
                editingWorkout: $editingWorkout,
                disabledEditButton: $disabledEditButton,
                searchQuery: $searchQuery,
                showAdded: $showAdded,
                showDeleted: $showDeleted,
                showCompleted: $showCompleted,
                showIncomplete: $showIncomplete,
                darkMode: darkMode,
                workoutTypes: workoutTypes
            )
                
        case "Settings":
            SettingsView(
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                showingCalendar: $showingCalendar,
                showingSettings: $showingSettings,
                darkMode: $darkMode,
                workoutTypes: $workoutTypes,
                suggestedWorkoutTypes: $suggestedWorkoutTypes
            )
                
        default:
            CompletedView(
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                showingCalendar: $showingCalendar,
                showingSettings: $showingSettings,
                showingAddWorkout: $showingAddWorkout,
                editingWorkout: $editingWorkout,
                disabledEditButton: $disabledEditButton,
                searchQuery: $searchQuery,
                showAdded: $showAdded,
                showDeleted: $showDeleted,
                showCompleted: $showCompleted,
                showIncomplete: $showIncomplete,
                animateAddedCircle: $animateAddedCircle,
                animateDeletedCircle: $animateDeletedCircle,
                animateCompletedCircle: $animateCompletedCircle,
                animateIncompleteCircle: $animateIncompleteCircle,
                filterTypeCompleted: $filterTypeCompleted,
                sortOrder: $sortOrder,
                darkMode: darkMode,
                workoutTypes: workoutTypes,
                loadItems: loadItems
            )
        }
    }
    
    func loadItems() {
        if let savedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey) as? [String] {
            workoutTypes = savedWorkoutTypes
        }
            
        if let savedSuggestedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey2) as? [String] {
            suggestedWorkoutTypes = savedSuggestedWorkoutTypes
        }
    }
    
    
}


