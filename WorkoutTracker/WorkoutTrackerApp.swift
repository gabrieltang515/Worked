
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Rafael Soh on 26/4/24.
//

import SwiftUI
import SwiftData
import Combine

@main
struct WorkoutTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Workout.self)

    }
}
