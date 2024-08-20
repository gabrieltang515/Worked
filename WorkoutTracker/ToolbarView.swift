//
//  ToolbarView.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 8/7/24.
//

import Foundation
import SwiftUI

//struct ToolbarView: View {
//    @Binding var filterTypeCompleted: String
//    @Binding var filterTypeLapsed: String
//    @Binding var filterTypeUpcoming: String
//    var workoutTypes: [String]
//    @Binding var showingAddWorkout: Bool
//    
//    var body: some View {
//
//        .toolbar {
//            ToolbarItemGroup(placement: .topBarTrailing) {
//                Menu("Sort", systemImage: "arrow.up.arrow.down.square") {
//                    Picker("Sort", selection: $filterTypeCompleted) {
//                        ForEach(["All"] + workoutTypes, id: \.self) {
//                            Text("\($0) Workouts")
//                                .monospaced()
//                        }
//                    }
//                }
//
//                
//                Button(action: {
//                    showingAddWorkout.toggle()
//             })  {
//                    Label("New Workout", systemImage: "plus.square")
//                }
//                .monospaced()
//            }
//            
//            
//            
//            
//            ToolbarItem(placement: .topBarLeading) {
//                    EditButton()
//                    .monospaced()
//            }
//        } // .toolbar
//    } // Body Bracket
//}
