import SwiftUI

struct PushNotifications: View {
    @State private var pushEnabled: Bool = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Push Notifications", isOn: $pushEnabled)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Push Notifications")
                    .monospaced()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


