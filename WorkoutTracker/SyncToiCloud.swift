import SwiftUI

struct SyncToiCloud: View {
    @AppStorage("iCloudSyncEnabled") private var syncEnabled: Bool = false
    
    var body: some View {
        Form {
            Section(footer: Text("Quit and reload app to view changes")) {
                Toggle("Sync to iCloud", isOn: $syncEnabled)
            }
        }
        .navigationTitle("Sync to iCloud")
        .navigationBarTitleDisplayMode(.inline)
    }
}


