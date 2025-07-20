import SwiftUI
import SwiftData

struct SettingsTabView: View {
    // MARK: - State Variables
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    @Binding var showingCalendar: Bool
    @Binding var showingSettings: Bool
    @Binding var darkMode: Bool
    @Binding var workoutTypes: [String]
    @Binding var suggestedWorkoutTypes: [String]
    
    var body: some View {
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
    }
} 