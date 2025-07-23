import SwiftUI
import AuthenticationServices

struct LinkToStrava: View {
    @State private var isAuthenticating = false
    @State private var authResult: String? = nil
    @State private var contextProvider = ContextProvider()
    @State private var authSession: ASWebAuthenticationSession? // Keep a strong reference

    // Replace with your actual Strava client ID, client secret, and redirect URI
    private let clientID = "168700"
    private let clientSecret = "be1f9e89c1a8218ff688b3a52295db5b366fe252"
    private let redirectURI = "https://b0a2403f35c9.ngrok-free.app/strava-callback" // e.g., "yourapp://strava-callback"
    private let scope = "activity:read_all,profile:read_all"

    var body: some View {
        VStack(spacing: 24) {
            Button(action: startStravaLogin) {
                HStack {
                    Text("Link Strava Account")
                        .font(.headline)
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isAuthenticating)

            if isAuthenticating {
                ProgressView("Authorizing with Strava...")
            }

            if let result = authResult {
                Text(result)
                    .foregroundColor(result.contains("Success") ? .green : .red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private func startStravaLogin() {
        isAuthenticating = true
        authResult = nil
        let authURL = URL(string:
            "https://www.strava.com/oauth/mobile/authorize?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code&approval_prompt=auto&scope=\(scope)"
        )!
        // Use your custom scheme ("Worked") for callbackURLScheme
        authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "Worked"
        ) { callbackURL, error in
            isAuthenticating = false
            if let error = error {
                print("ASWebAuthenticationSession error: \(error.localizedDescription)")
                authResult = "Error: \(error.localizedDescription)"
                return
            }
            guard let callbackURL = callbackURL else {
                print("No callback URL received.")
                authResult = "Error: Invalid callback URL (no callback)"
                return
            }
            print("Received callback URL: \(callbackURL)")
            // If you are using a backend, you will not get the code here, but the app will be opened via .onOpenURL
            // So just show a message and let .onOpenURL handle the token storage
            authResult = "Success! Please wait while we finish linking your Strava account."
        }
        authSession?.presentationContextProvider = contextProvider
        authSession?.prefersEphemeralWebBrowserSession = true
        authSession?.start()
    }

    private func exchangeCodeForToken(code: String) {
        guard let url = URL(string: "https://www.strava.com/oauth/token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI
        ]
        request.httpBody = params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    authResult = "Token Error: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    authResult = "Token Error: Invalid response"
                }
                return
            }
            if let accessToken = json["access_token"] as? String,
               let refreshToken = json["refresh_token"] as? String {
                // Store tokens securely
                KeychainHelper.shared.save(Data(accessToken.utf8), service: "strava", account: "access_token")
                KeychainHelper.shared.save(Data(refreshToken.utf8), service: "strava", account: "refresh_token")
                DispatchQueue.main.async {
                    authResult = "Success! Strava account linked."
                }
            } else if let message = json["message"] as? String {
                DispatchQueue.main.async {
                    authResult = "Token Error: \(message)"
                }
            } else {
                DispatchQueue.main.async {
                    authResult = "Token Error: Unknown error"
                }
            }
        }
        task.resume()
    }
}

class ContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Modern window scene approach
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        return ASPresentationAnchor()
    }
}
