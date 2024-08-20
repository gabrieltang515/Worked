////
////  SwipeActionsAndAlerts.swift
////  WorkoutTracker
////
////  Created by Gabriel Tang on 22/7/24.
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//
//struct SwipeActionsAndAlerts: ViewModifier {
//    @Environment(\.modelContext) var modelContext
//    @Binding var showingDeleteAlert: Bool
//    @Binding var editingWorkout: Bool
//    
//    
//    
//    func body(content: Content) -> some View {
//        content
//            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                Button {
//            //  deleteSingleWorkout(workout: workout)
//                showingDeleteAlert.toggle()
//            } label: {
//                Label("delete", systemImage: "trash.fill")
//                .tint(.red)
//                }
//            }
//        
//            .alert("Delete Workout", isPresented: $showingDeleteAlert) {
//                Button("Delete", role: .destructive, action: {modelContext.delete(workout)} )
//                Button("Cancel", role: .cancel) {}
//            } message: {
//                Text("Are you sure you want to delete this workout permanently?")
//            }
//        
//            .swipeActions(edge: .leading, allowsFullSwipe: false) {
//                Button {
//                    editingWorkout.toggle()
//                    //                        editMode?.wrappedValue = .active
//                } label: {
//                    Label("edit", systemImage: "pencil")
//                }
//                .tint(.green)
//                
//                Button {
//                    if workout.favourites == false {
//                        markAsFavouriteAlert.toggle()
//                    } else {
//                        unmarkAsFavouriteAlert.toggle()
//                    }
//                    
//                } label: {
//                    if workout.favourites == false {
//                        Label("mark as favourite", systemImage: "heart.fill")
//                    } else {
//                        Label("unmark as favourite", systemImage: "heart.slash.fill")
//                    }
//                }
//                .tint(.yellow)
//            }
//        
//            .alert("Mark as Favourite", isPresented: $markAsFavouriteAlert) {
//                Button("Mark as Favourite", action: {workout.favourites = true})
//                Button("Cancel", role: .cancel) {}
//            } message: {
//                Text("Mark this workout as a Favourite?")
//            }
//        
//            .alert("Unmark as Favourite", isPresented: $unmarkAsFavouriteAlert) {
//                Button("Unmark as Favourite", action: {workout.favourites = false})
//                Button("Cancel", role: .cancel) {}
//            } message: {
//                Text("Unmark this workout as a Favourite?")
//            }
//        
//        
//            .sheet(isPresented: $editingWorkout) {
//                EditWorkoutView(workout: workout, workoutTypes: workoutTypes, selectedTab: selectedTab, darkMode: darkMode)
//            }
//    }
//}
