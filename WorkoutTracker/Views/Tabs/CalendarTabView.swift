import SwiftUI
import SwiftData

struct CalendarTabView: View {
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    @Binding var showingCalendar: Bool
    @Binding var showingSettings: Bool
    @Binding var showingAddWorkout: Bool
    @Binding var editingWorkout: Bool
    @Binding var disabledEditButton: Bool
    @Binding var searchQuery: String
    @Binding var showAdded: Bool
    @Binding var showDeleted: Bool
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    
    let darkMode: Bool
    let workoutTypes: [String]
    
    @State private var selectedDate: Date? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                CalendarView(
                    date: Date.now,
                    editButtonDisabled: $disabledEditButton,
                    showingAddWorkout: $showingAddWorkout,
                    editingWorkout: $editingWorkout,
                    darkMode: darkMode,
                    selectedTab: $selectedTab,
                    selectedTabString: selectedTab,
                    showingCompleted: $showingCompleted,
                    showingLapsed: $showingLapsed,
                    showingUpcoming: $showingUpcoming,
                    workoutTypes: workoutTypes,
                    showDeleted: $showDeleted,
                    showAdded: $showAdded,
                    searchQuery: $searchQuery,
                    showCompleted: $showCompleted,
                    showIncomplete: $showIncomplete,
                    selectedDate: $selectedDate
                )
                .toolbar {
                    ToolbarItemGroup(placement: .principal) {
                        Text(selectedTab)
                            .font(.title3)
                            .padding(20)
                    }
                    
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showingAddWorkout.toggle()
                        } label: {
                            Image(darkMode ? "icons8-add-v3-100-darkmode" : "icons8-add-v3-100-lightmode")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .scaledToFit()
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingAddWorkout) {
                    AddWorkout(
                        darkMode: darkMode,
                        selectedTab: $selectedTab,
                        showingCompleted: $showingCompleted,
                        showingLapsed: $showingLapsed,
                        showingUpcoming: $showingUpcoming,
                        workoutTypes: workoutTypes,
                        showAdded: $showAdded,
                        initialDate: selectedDate ?? Date.now
                    )
                }
            }
            
            Spacer()
            
            BottomBarView(
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                showingCalendar: $showingCalendar,
                showingSettings: $showingSettings,
                darkMode: .constant(darkMode)
            )
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
        } // NavigationStack
        .preferredColorScheme(darkMode ? .dark: .light)
        .accentColor(darkMode ? .white: .black)
        .monospaced()
    }
}
