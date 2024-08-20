//
//  WorkoutsViewHStack.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 29/7/24.
//

import Foundation
import SwiftUI

struct WorkoutsViewHStack: View {
    var workout: Workout
    var darkMode: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            VStack {
                Text(workout.formattedDateMonth)
                    .font(.headline.monospaced())
                Text(workout.formattedDateDate)
                    .font(.headline.monospaced())
            }
            .padding(12)
            .overlay(
                Rectangle()
                    .stroke((darkMode ? Color.white: Color.black), lineWidth: 2)
            )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(workout.workoutType)
                    .font(.headline.monospaced())
                Text(workout.workoutDescription)
                    .foregroundStyle(.secondary)
                    .font(.subheadline.monospaced())
            }
            
            Spacer()
            if workout.favourites == true {
                Image(systemName: "heart.fill")
                    .resizable()
                    .foregroundStyle(.red)
                    .frame(width: 18, height: 15)
                    .scaledToFit()
            }
            
        }
        .frame(maxHeight: 68)// HStack Bracket
    }
}
