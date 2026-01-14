//
//  FavouritesSetting.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 22/7/24.
//

import Foundation
import SwiftUI
import SwiftData

struct FavouritesSetting: View {
    @Query var workouts: [Workout]
    var workoutTypes: [String]
    var darkMode: Bool
    
    @State private var editingWorkout = false
    
    // zeng
    @State private var showDeleted = false
    @State private var showCompleted = false
    @State private var showIncomplete = false
    
    var favouriteWorkouts: [Workout] {
        let favouriteItems = workouts.compactMap { workout in
            if workout.favourites == true {
                return workout
            } else {
                return nil
            }
        }
        
        return favouriteItems
    }
    
    var body: some View {
        ZStack {
            if favouriteWorkouts.isEmpty {
                ContentUnavailableView {
                    Label("No Favourites Yet", systemImage: "heart.fill")
                        .padding()
                    
                    Text("Mark a workout as a Favourite to view it here.")
                        .font(.subheadline)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Favourites")
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                
            } else {
                List {
                    ForEach(favouriteWorkouts, id: \.id) { workout in
                        FavouritesSetting2(workout: workout, workoutTypes: workoutTypes, darkMode: darkMode, editingWorkout: $editingWorkout, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
                        
                    } // For each
                } // List
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Favourites")
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }

            


            
            
            
            
        } // ZStack Bracket

        
        
    } // body bracket
} // struct bracket



struct FavouritesSetting2: View {
    var workout: Workout
    var workoutTypes: [String]
    var darkMode: Bool
    
    @Binding var editingWorkout: Bool
    @Binding var showDeleted: Bool
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    
    @State private var showingDeleteAlert = false
    
    @State private var markAsCompletedAlert = false
    @State private var markAsIncompleteAlert = false
    
    @State private var markAsFavouriteAlert = false
    @State private var unmarkAsFavouriteAlert = false
    
    

    
    
    var body: some View {
        NavigationLink {
            WorkoutView(workout: workout, workoutTypes: workoutTypes, darkMode: darkMode, selectedTab: "Completed", showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
        } label: {
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
            } // HStack Bracket
            .frame(maxHeight: 68)
            
        } // Label Bracket
        
        .modifier(SwipeActionsAndAlertsModifiers(workout: workout, showingDeleteAlert: $showingDeleteAlert, showDeleted: $showDeleted, editingWorkout: $editingWorkout, markAsFavouriteAlert: $markAsFavouriteAlert, unmarkAsFavouriteAlert: $unmarkAsFavouriteAlert, selectedTab: "Completed", markAsCompletedAlert: $markAsCompletedAlert, markAsIncompleteAlert: $markAsIncompleteAlert, showCompleted: $showCompleted, showIncomplete: $showIncomplete))
        
        .fullScreenCover(isPresented: $editingWorkout) {
            EditWorkoutView(workout: workout, workoutTypes: workoutTypes, selectedTab: .constant("Completed"), showingCompleted: $showCompleted, showingLapsed: .constant(false), showingUpcoming: .constant(false), darkMode: darkMode)
        }
        
    }
}
