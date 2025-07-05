import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    // Persisted user‐choice
    @AppStorage("iCloudSyncEnabled") private var syncToiCloud: Bool = false
    private let container: ModelContainer
    
    init() {
        let initial = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        
        // Pick which Model Configuration to use
        let config = initial
            ? Self.makeCloudConfig()
            : Self.makeLocalConfig()
        
        do {
            container = try ModelContainer(for: Workout.self,
                                           configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        
        print("🔍 Starting with iCloudSyncEnabled = \(initial)")
    }
    
    private static func makeCloudConfig() -> ModelConfiguration {
        let schema = Schema([Workout.self])
        let group = ModelConfiguration.GroupContainer.none
        let ckDatabase   = ModelConfiguration.CloudKitDatabase.private("iCloud.com.gabrieltang.Worked")
        return ModelConfiguration(
            nil,
            schema:               schema,
            isStoredInMemoryOnly: false,
            allowsSave:           true,
            groupContainer:       group,
            cloudKitDatabase:     ckDatabase
        )
        
    }
    
    private static func makeLocalConfig() -> ModelConfiguration {
        ModelConfiguration(isStoredInMemoryOnly: false)
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
