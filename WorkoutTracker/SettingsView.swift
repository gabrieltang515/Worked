import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode

    // MARK: – bindings from parent
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    @Binding var showingCalendar: Bool
    @Binding var showingSettings: Bool
    @Binding var darkMode: Bool

    // MARK: – local state
    @State private var selectedMode = "System"
    @Binding var workoutTypes: [String]
    @Binding var suggestedWorkoutTypes: [String]
    @State private var originalSuggestedWorkoutTypes = [
      "Run","Walk","Gym","Swim","Cycle","Yoga",
      "Football","Basketball","Bouldering","Pilates","Spin","Calisthenics"
    ]
    @State private var newCategory = ""
    private var disableField: Bool { newCategory.count < 3 }

    // MARK: – templates storage
    @AppStorage("workoutTemplates") private var workoutTemplatesData: Data = Data()
    @State private var workoutTemplates: [WorkoutTemplate] = []
    @State private var showBottombar: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            navigationStack
            bottomBar
        }
        .onAppear {
            if let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: workoutTemplatesData) {
                workoutTemplates = decoded
            }
        }
        .onChange(of: workoutTemplates) { old, new in
            if let encoded = try? JSONEncoder().encode(new) {
                workoutTemplatesData = encoded
            }
        }
    }

    // MARK: – the navigation + form
    private var navigationStack: some View {
        NavigationStack {
            Form {
                generalSection
                workoutsSection
                dataSection
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.title)
                        .monospaced()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        .accentColor(darkMode ? .white : .black)
        .monospaced()
    }

    // MARK: – "General" section
    @ViewBuilder private var generalSection: some View {
        Section("General") {
            NavigationLink {
                AppearanceSetting(darkMode: $darkMode, selectedMode: $selectedMode)
                    .onAppear { showBottombar = false }
                    .onDisappear { showBottombar = true }
            } label: { Text("Appearance") }
            NavigationLink {
                FavouritesSetting(
                    selectedTab: selectedTab,
                    workoutTypes: workoutTypes,
                    darkMode: darkMode)
                    .onAppear { showBottombar = false }
                    .onDisappear { showBottombar = true }
            } label: { Text("Favourites") }
            NavigationLink {
                PushNotifications()
                    .onAppear { showBottombar = false }
                    .onDisappear { showBottombar = true }
            } label: { Text("Push Notifications") }
            
//            NavigationLink { Text("Coming Soon") }
//                           label: { Text("Lock with Face ID") }
        }
    }

    @ViewBuilder private var workoutsSection: some View {
        Section("Workout") {
          Group {
            NavigationLink {
              WorkoutTypeSetting(
                workoutTypes: $workoutTypes,
                suggestedWorkoutTypes: $suggestedWorkoutTypes,
                originalSuggestedWorkoutTypes: originalSuggestedWorkoutTypes,
                newCategory: $newCategory
              )
              .onAppear { showBottombar = false }
              .onDisappear { showBottombar = true }
            } label: {
              Text("Categories")
            }

            NavigationLink {
              WorkoutTemplateSetting(
                templates: $workoutTemplates,
                darkMode: darkMode,
                workoutTypes: $workoutTypes,
                showBottombar: $showBottombar
              )
              .onAppear { showBottombar = false }
              .onDisappear { showBottombar = true }
            } label: {
              Text("Templates")
            }

          }
        }
    }

    // MARK: – "Data" section
    @ViewBuilder private var dataSection: some View {
        Section("Data") {
            NavigationLink {
                SyncToiCloud()
                    .onAppear { showBottombar = false }
                    .onDisappear { showBottombar = true }
            } label: { Text("Sync to iCloud") }

//            NavigationLink {
//                LinkToStrava()
//            } label: {
//                Text("Link to Strava")
//            }
        }
    }

    // MARK: – bottom tab bar
    private var bottomBar: some View {
        Group {
            if showBottombar {
                BottomBarView(
                    selectedTab: $selectedTab,
                    showingCompleted: $showingCompleted,
                    showingLapsed: $showingLapsed,
                    showingUpcoming: $showingUpcoming,
                    showingCalendar: $showingCalendar,
                    showingSettings: $showingSettings,
                    darkMode: $darkMode
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showBottombar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
