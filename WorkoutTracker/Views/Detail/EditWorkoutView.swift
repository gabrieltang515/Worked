//
//  EditWorkoutView.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 18/7/24.
//

import Foundation
import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    @Bindable var workout: Workout
    
    var workoutTypes: [String]
    
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    
    var darkMode: Bool
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    
    
    var body: some View {
        NavigationStack {
//            HStack(alignment: .center) {
//                Text("Edit Workout")
//                    .bold()
//                    .frame(width: 100)
//                    .padding()
//                
//                Spacer()
//                
//                Button("Done") {
//                    dismiss()
//                    
//                    if workout.date <= Date.now {
//                        withAnimation {
//                            selectedTab = "Completed"
//                            showingCompleted = true
//                            showingLapsed = false
//                            showingUpcoming = false
//                        }
//                    } else {
//                        withAnimation {
//                            selectedTab = "Upcoming"
//                            showingCompleted = false
//                            showingLapsed = false
//                            showingUpcoming = true
//                        }
//                    }
//                }
//                .foregroundStyle(.primary)
//                .padding(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(.primary, lineWidth: 2)
//                )
//                .padding()
//                
//            }
            
            Form {
                Picker("Workout Type", selection: $workout.workoutType) {
                    ForEach(workoutTypes, id: \.self) {
                        Text($0)
                    }
                }

                Section("Workout Description") {
                        TextEditor(text: $workout.workoutDescription)
                            .frame(minHeight: 100)
                            .padding(10)
                            .border(Color.gray)
                            .padding([.top, .bottom], 15)
                }


                Section("Location") {
                    TextField("Location", text: $workout.location)
                }
                
                Section("Date and Time") {
                    DatePicker("Date and time", selection: $workout.date, in: Date.distantPast...Date.distantFuture)
                        .labelsHidden()
                        .padding(3)
                }
            
            } // Form Bracket
            .preferredColorScheme(darkMode ? .dark: .light)
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Edit Workout")
                        .font(.title3)
                        .padding()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                        
                        if workout.date <= Date.now {
                            withAnimation {
                                selectedTab = "Completed"
                                showingCompleted = true
                                showingLapsed = false
                                showingUpcoming = false
                            }
                        } else {
                            withAnimation {
                                selectedTab = "Upcoming"
                                showingCompleted = false
                                showingLapsed = false
                                showingUpcoming = true
                            }
                        }
                        
                    }
                    .foregroundStyle(.primary)
                    .padding(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(.primary, lineWidth: 2)
//                    )
//                    .padding()
                }
                
                
            }
            
//            .onTapGesture {
//                self.hideKeyboard()
//            }

            
            
        } // Navigation Stack
    }
}
