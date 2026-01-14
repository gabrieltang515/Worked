import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 1) Set yourself as UNUserNotificationCenter’s delegate
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // 2) Ask for permission
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("🔴 Notification permission error:", error)
                return
            }
            guard granted else {
                print("🔴 User denied notifications")
                return
            }
            // 3) Register for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return true
    }
    
    // 4) APNs gave us a device token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("✅ APNs Device Token:", tokenString)
        
        // Send to backend
        sendDeviceTokenToServer(tokenString)
    }
    
    // 5) Registration failed
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for APNs:", error.localizedDescription)
    }
    
    // 6) Handle a notification in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner, sound, badge even if app is frontmost
        completionHandler([.banner, .sound, .badge])
    }
    
    private func sendDeviceTokenToServer(_ token: String) {
        guard let url = URL(string: "http://192.168.81.104:3000/api/device-tokens") else {
            print("🔴 Invalid URL")
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [  // however you identify users
            "deviceToken": token
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req) { _, resp, err in
            if let err = err {
                print("🔴 Token upload error:", err)
            } else {
                print("✅ Token uploaded; server response:", resp as Any)
            }
        }.resume()
    }
}
