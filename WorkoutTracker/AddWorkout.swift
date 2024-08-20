//
//  AddWorkout.swift
//  WorkoutTracker
//
//  Created by Rafael Soh on 26/4/24.
//

import SwiftUI
import SwiftData
import Foundation
import CoreLocation
import CoreLocationUI


struct AddWorkout: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    //Receiving Variables
    var darkMode: Bool
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    
    var workoutTypes: [String]
    
    // Added alert
    @Binding var showAdded: Bool
    
    // Internal Variables
    @State private var workoutDescription = ""
    @State private var workoutType = "Run"
    @State private var location = ""
    @State private var date = Date.now
    
    @FocusState private var descriptionIsFocused: Bool
    @FocusState private var locationIsFocused: Bool
    @State private var isKeyboardVisible = false



    // For keyboard
//    @State private var isKeyboardVisible = false
    
    var body: some View {
//        ZStack {
        
            NavigationStack {
    //            Text("New Workout")
    //                .font(.title2)
    //                .foregroundStyle(.secondary)
    //                .padding(.top, 20)
                
                Form {
                    Section {
                        Picker("Workout Type", selection: $workoutType) {
                            ForEach(workoutTypes, id: \.self) {
                                Text($0)
                            }
                        }
                    }

                    
                    Section("Workout Description") {
                        TextEditor(text: $workoutDescription)
                            .frame(minHeight: 100)
                            .padding(10)
                            .border(Color.gray)
                            .padding([.top, .bottom], 15)
                            .focused($descriptionIsFocused)
                        
//                            .onReceive(keyboardPublisher) { newIsKeyboardVisible in
//                                print("Is Keybboard visible?" , newIsKeyboardVisible)
//                                isKeyboardVisible = newIsKeyboardVisible
//                            }
//                            .disabled(isKeyboardVisible)
                        
                        
                    }

                    Section {
                        TextField("Type location", text: $location)
                            .focused($locationIsFocused)
                    } header: {
                        Text("Location")
                    }
                    
                    Section("Date and Time") {
                        DatePicker("Date and time", selection: $date, in: Date.distantPast...Date.distantFuture)
                            .labelsHidden()
                            .padding(3)
                    }

                } // Form Bracket
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            descriptionIsFocused = false
                            locationIsFocused = false
                        } label: {
                            Image(darkMode ? "icons8-keyboard-96-darkmode": "icons8-keyboard-96-lightmode")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .scaledToFit()
                        }
                        .foregroundStyle(.primary)
                        
                        
                        
                            Button {
                                dismiss()
                            } label: {
                                Image(darkMode ? "icons8-close-outlined-darkmode": "icons8-close-outlined-lightmode" )
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .scaledToFit()
                            }
                    }
                    
                    ToolbarItem(placement: .status) {

                        Button {
                            let newWorkout = Workout(workoutDescription: (workoutDescription.isEmpty ? "No description" : workoutDescription), workoutType: workoutType, location: (location.isEmpty ? "Unknown location" : location), date: date, isCompleted: (date <= Date.now ? true : false), favourites: false )
                            
                            modelContext.insert(newWorkout)

                            
                            // adjustment of tab
                            if date <= Date.now {
                                    selectedTab = "Completed"
                                    showingCompleted = true
                                    showingLapsed = false
                                    showingUpcoming = false
                            } else {

                                    selectedTab = "Upcoming"
                                    showingCompleted = false
                                    showingLapsed = false
                                    showingUpcoming = true
                            }
                            
                            dismiss()
                            
                            showAdded = true
                            
                            
                            
                        } label: {
                            HStack(spacing: 10) {
                                
                                Text("Add")
                                    .foregroundStyle(.primary)

                                Image(darkMode ? "icons8-download-100-darkmode": "icons8-download-100-lightmode")
                                    .resizable()
                                    .frame(width: 25, height: 25)
    //                                .scaledToFit()
                                    .padding(.bottom, 5)

                            }
                            
                        } // label for button bracket
                        .foregroundStyle(.primary)
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke((darkMode ? Color.white : Color.black), lineWidth: 1.5)
                        )
                        
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Add Workout")
                            .font(.title3)
                            .padding()
                    }
                    
                    
                } // toolbar bracket
                
    //            Button("Add", systemImage: "square.and.arrow.down" ) {
    //                let newWorkout = Workout(workoutDescription: (workoutDescription.isEmpty ? "No description" : workoutDescription), workoutType: workoutType, location: (location.isEmpty ? "Unknown location" : location), date: date, isCompleted: (date <= Date.now ? true : false), favourites: false )
    //
    //                modelContext.insert(newWorkout)
    //                dismiss()
    //
    //                // adjustment of tab
    //                if date <= Date.now {
    //                    withAnimation {
    //                        selectedTab = "Completed"
    //                        showingCompleted = true
    //                        showingLapsed = false
    //                        showingUpcoming = false
    //                    }
    //                } else {
    //                    withAnimation {
    //                        selectedTab = "Upcoming"
    //                        showingCompleted = false
    //                        showingLapsed = false
    //                        showingUpcoming = true
    //                    }
    //                }
    //
    //            }
    //            .foregroundStyle(.primary)
    //            .padding(12)
    //            .overlay(
    //                RoundedRectangle(cornerRadius: 10)
    //                    .stroke((darkMode ? Color.white : Color.black), lineWidth: 2)
    //            )
                
    //            Spacer()
                
//                .onTapGesture {
//                    self.hideKeyboard()
//                }
                
                
            } // Navigation Stack Bracket
            .preferredColorScheme(darkMode ? .dark: .light)
        

//        } // ZStack

        
        
    }
}

//extension View {
//    
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}



//#Preview {
//    AddWorkout()
//}
