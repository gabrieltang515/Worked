//
//  WorkoutView.swift
//  WorkoutTracker
//
//  Created by Rafael Soh on 27/4/24.
//

import SwiftUI
import SwiftData


struct WorkoutView: View {
    // External Properties
    @Bindable var workout: Workout
    
    // need selectedTab to determine whether to show mark as completed
    var selectedTab: String
    var workoutTypes: [String]
    var darkMode: Bool
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    
    // to show "zeng" alerts when a workout is deleted/mark as complete (or incomplete) / when duplicated (coming soon)
    @Binding var showDeleted: Bool
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    
    // Internal Properties
    // Edit mode and alerts
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingCompletedAlert = false
    @State private var showingIncompleteAlert = false
    
    // For Keyboard Focus
    @FocusState private var descriptionIsFocused: Bool
    @FocusState private var locationIsFocused: Bool
    
    var body: some View {
        NavigationStack {
            if editMode?.wrappedValue.isEditing == true {
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
                                .focused($descriptionIsFocused)
                    }


                    Section("Location") {
                        TextField("Location", text: $workout.location)
                            .focused($locationIsFocused)
//                            .kerning(-1.5)
                    }
                    
                    Section("Date and Time") {
                        DatePicker("Date and time", selection: $workout.date, in: Date.distantPast...Date.distantFuture)
                            .labelsHidden()
                            .padding(3)
                    }
                
                } // Form Bracket
                .preferredColorScheme(.dark)
                .scrollBounceBehavior(.basedOnSize)
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
                        
                        EditButton()
                    }

                    
                    // change this!!
                }
                
//                .onTapGesture {
//                    self.hideKeyboard()
//                }
                
                
            } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(workout.workoutType)
                                .frame(width: 368, alignment: .center)
                                .padding([.horizontal, .bottom])
                                .font(.title.bold().monospaced())
                            
        //                        .clipShape(.rect(cornerRadius: 10))
        //                        .overlay (
        //                            RoundedRectangle(cornerRadius: 10)
        //                                .opacity(0.2)
        //                        )
                            
                            Text("Workout Description")
                                .font(.title3/*.italic()*/.monospaced())
                                .padding([.horizontal, .top])
                        
                            // old workout description
                            
                            
//                            Text(workout.workoutDescription)
//                                .font(.system(size: 18).monospaced())
//                                .foregroundStyle(.secondary) // or use secondary colour
//                                .padding(11)
//                                .frame(minWidth: 230, idealWidth: 325, maxWidth: 400, minHeight: 65, maxHeight: .infinity, alignment: .center)
//                                .overlay (
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .opacity(0.2)
//                                    )
//                                .padding(.horizontal)
                            
                            Text(workout.workoutDescription)
                                .font(.system(size: 18).monospaced())
                                .foregroundStyle(.secondary) // or use secondary colour
                                .padding(15)
                                .frame(width: 368)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .overlay (
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.2)
                                    )
                                .padding(.horizontal)

                                    
                                Text("\(workout.location), \(workout.formattedDate)")
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .font(.subheadline.monospaced())
                            
                                    
//                            Spacer(minLength: 175)
                            

                        } // VStack Bracket
                    } // Scroll View Bracket
                    .preferredColorScheme(.dark)
                    .scrollBounceBehavior(.basedOnSize)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                // Edit button, Duplicate button, Delete button, Mark as completed button (if under lapsed) should be created here
                                // Maybe change the system images to icons8 images
                                Button {
                                    isEditing.toggle()
                                    editMode?.wrappedValue = .active
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                
                                Button("Duplicate workout", systemImage: "doc.on.doc", action: duplicateWorkout)
                                
                                // insert alert for workout deletion
                                Button("Delete workout", systemImage: "trash") {
                                    showingDeleteAlert = true
                                }
                                
                                if selectedTab == "Completed" || selectedTab == "Lapsed" {
                                    Button(selectedTab == "Completed" ? "Mark as Incomplete": "Mark as Completed", systemImage: selectedTab == "Completed" ? "bookmark.slash" : "bookmark") {
                                        selectedTab == "Completed" ? showingIncompleteAlert.toggle() : showingCompletedAlert.toggle()
//                                        workout.isCompleted.toggle()
//                                        dismiss()
                                        
                                        
                                    }
                                }

                            } label: {
                                Image(darkMode ? "icons8-dots-100-darkmode": "icons8-dots-100-lightmode")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .scaledToFit()
                            } // Menu bracket
                        } // toolbar item bracket
                        
//                        if selectedTab == "Past Workouts" || selectedTab == "Lapsed" {
//                            ToolbarItem(placement: .status) {
//                                Button {
//                                    workout.isCompleted.toggle()
//                                    dismiss() // can animation for this maybe???
//                                } label: {
//                                    ZStack(alignment: .center) {
//                                        Text(selectedTab == "Past Workouts" ? "Mark as Incomplete": "Mark as Completed")
//                                        .frame(width: 150)
//                                        .foregroundStyle(.primary)
//                                        .font(.system(size: 15).monospaced())
//                                        
//
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(.white, lineWidth: 3)
//                                            .fill(.clear)
//                                            .frame(width: 250, height: 35)
//                                            
//                                    }
//                                    .padding(.bottom, 35)
//                                }
//                            }
//                        } // if bracket
//
                        
                    } // toolbar bracket
                
                    .onChange(of: editMode?.wrappedValue, initial: true) {
                        isEditing = false
                    }
                
                    .alert("Delete Workout", isPresented: $showingDeleteAlert) {
                        Button("Delete", role: .destructive, action: deleteWorkout)
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete this workout permanently?")
                    }
                
                    .alert("Mark as Completed", isPresented: $showingCompletedAlert) {
                        Button("Mark as Completed", action: {
                            workout.isCompleted = true
//                            showCompleted.toggle()
                            dismiss()
                        })
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Mark this workout as Completed?")
                    }
                
                    .alert("Mark as Incomplete", isPresented: $showingIncompleteAlert) {
                        Button("Mark as Incomplete", action: {
                            workout.isCompleted = false
//                            showIncomplete.toggle()
                            dismiss()
                        })
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Mark this workout as Incomplete?")
                    }
                
                    .animation(.easeInOut(duration: 3.0), value: isEditing)
                
                
            } // "else" bracket
        } // Navigation Stack bracket
        
    } // Body Bracket
    
    func duplicateWorkout() {
        let newWorkout = Workout(workoutDescription: (workout.workoutDescription.isEmpty ? "No description" : workout.workoutDescription), workoutType: workout.workoutType, location: (workout.location.isEmpty ? "Unknown location" : workout.location), date: workout.date, isCompleted: (workout.date <= Date.now ? true : false), favourites: workout.favourites )
        modelContext.insert(newWorkout)
        dismiss()
    }
    
    func deleteWorkout() {
        modelContext.delete(workout)
        dismiss()
    }
    
    
} // Workout View Struct Bracket






//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: Workout.self, configurations: config)
//        
//        let example = Workout(workoutDescription: "Nice workout", workoutType: "Run", location: "Serangoon", date: Date.now)
//        
//        return WorkoutView(workout: example)
//            .modelContainer(container)
//        
//    } catch {
//        return Text("Failed to create preview: \(error.localizedDescription)")
//    }
//}

