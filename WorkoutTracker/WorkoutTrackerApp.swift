import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    // Persisted user‐choice
    @AppStorage("iCloudSyncEnabled") private var syncToiCloud: Bool = false
    private let container: ModelContainer
    
    @StateObject private var keyboardResponder = KeyboardResponder()
    
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
                .environmentObject(keyboardResponder) // Inject singleton
                .onOpenURL { url in
                    print("🔵 Received URL: \(url)")
                    print("🔵 URL scheme: \(url.scheme ?? "nil")")
                    print("🔵 URL host: \(url.host ?? "nil")")
                    print("🔵 URL path: \(url.path)")
                    print("🔵 URL query: \(url.query ?? "nil")")
                    
                    if (url.scheme?.lowercased() == "worked") && url.host == "strava-auth" {
                        print("✅ URL matches expected scheme and host")
                        
                        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                            print("✅ URLComponents created successfully")
                            print("🔵 Query items: \(components.queryItems ?? [])")
                            
                            if let accessToken = components.queryItems?.first(where: { $0.name == "access_token" })?.value,
                               let refreshToken = components.queryItems?.first(where: { $0.name == "refresh_token" })?.value {
                                
                                print("✅ Tokens extracted successfully")
                                print("🔵 Access token: \(String(accessToken.prefix(10)))...")
                                
                                // Store tokens securely
                                KeychainHelper.shared.save(Data(accessToken.utf8), service: "strava", account: "access_token")
                                KeychainHelper.shared.save(Data(refreshToken.utf8), service: "strava", account: "refresh_token")
                                
                                print("✅ Tokens stored in Keychain")
                            } else {
                                print("❌ Failed to extract tokens from query items")
                            }
                        } else {
                            print("❌ Failed to create URLComponents")
                        }
                    } else {
                        print("❌ URL does not match expected scheme or host")
                        print("   Expected scheme: Worked, got: \(url.scheme ?? "nil")")
                        print("   Expected host: strava-auth, got: \(url.host ?? "nil")")
                    }
                }
        }
    }
}
