import SwiftUI

struct SyncToiCloud: View {
    @AppStorage("iCloudSyncEnabled") private var syncEnabled: Bool = false
    
    var body: some View {
        Form {
            Section(footer: Text("Quit and reload app to view changes")) {
                Toggle("Sync to iCloud", isOn: $syncEnabled)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Text("Sync to iCloud")
                    .monospaced()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


