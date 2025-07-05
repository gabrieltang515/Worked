import SwiftUI

struct PushNotifications: View {
    @State private var pushEnabled: Bool = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Push Notifications", isOn: $pushEnabled)
            }
        }
        .navigationTitle("Push Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}


