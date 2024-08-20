//
//  WorkoutsView.swift
//  WorkoutTracker
//
//  Created by Rafael Soh on 28/4/24.
//

import SwiftUI
import SwiftData
import Foundation

struct WorkoutsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Query var workouts: [Workout]
    @Binding var editButtonDisabled: Bool
    @Binding var showingAddWorkout: Bool
    
    // For editing workout
    @Environment(\.editMode) var editMode
    @Binding var editingWorkout: Bool
    
 /*   var selectedWorkoutForEditing: Workout? {workouts.first}*/ // taken from @Query var workouts: [Workout]
    
    // For dark mode
    var darkMode: Bool
    
    // To push the right view after potential editing of date
    @Binding var selectedTab: String
    var selectedTabString: String
    
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    
    var workoutTypes: [String]
    var filterType: String


    // For delete alert
    @State private var showingDeleteAlert = false
    @Binding var showDeleted: Bool
    
    // For Search Bar
    @Binding var searchQuery: String
    var searchedWorkouts: [Workout] {
        if searchQuery.isEmpty {
            return workouts
        }
        
        let filteredItems = workouts.compactMap { workout in
            let descriptionContainsQuery = workout.workoutDescription.range(of: searchQuery, options: .caseInsensitive) != nil
            
            let typeContainsQuery = workout.workoutType.range(of: searchQuery, options: .caseInsensitive) != nil
            
            let locationContainsQuery = workout.location.range(of: searchQuery, options: .caseInsensitive) != nil
            
            let stringDateContainsQuery = workout.stringDate.range(of: searchQuery, options: .caseInsensitive) != nil
            
            
            return (descriptionContainsQuery || typeContainsQuery || locationContainsQuery || stringDateContainsQuery) ? workout: nil
        }
        
        return filteredItems
    }
    
    // For mark as favourite alert
//    @State private var markAsFavouriteAlert = false
//    @State private var unmarkAsFavouriteAlert = false
    
    // For completed alert
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    

    var body: some View {
        
//        HStack {
//            TextField("Search", text: $searchText)
//                .padding(7)
//                .padding(.horizontal, 25)
//                .background(Color(.systemGray6))
//                .overlay(
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 8)
//                    
//                    if !searchText.isEmpty {
//                        Button(action: {
//                            self.searchText = ""
//                        }) {
//                            Image(systemName: "multiply.circle.fill")
//                                .foregroundStyle(.gray)
//                                .padding(.trailing, 8)
//                        }
//                    }
//                }
//                    
//            )
//                .padding(.horizontal, 10)
//        }
        
        List {
            ForEach(searchedWorkouts, id: \.id) { workout in
                WorkoutsView2(workout: workout, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, darkMode: darkMode, editingWorkout: $editingWorkout, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
                
                
//                .onChange(of: editingWorkout) {
//                    EditWorkoutView(workout: workout, workoutTypes: workoutTypes, selectedTab: selectedTab)
//                }

                
            } // ForEach Bracket


        
//            .onDelete(perform: deleteWorkout)
            
//            .onChange(of: filterType) {
//                if workouts.isEmpty {
//                    editButtonDisabled = true
//                } else {
//                    editButtonDisabled = false
//                }
//            }
    
//            .onAppear() {
//                if workouts.isEmpty {
//                    editButtonDisabled = true
//                } else {
//                    editButtonDisabled = false
//                }
//            }
            
        } // List Bracket
        
        
//        .onAppear() {
//            if workouts.isEmpty {
//                editButtonDisabled = true
//            } else {
//                editButtonDisabled = false
//            }
//        }
        

        .searchable(text: $searchQuery/*, placement: .navigationBarDrawer(displayMode: .always)*/, prompt: "Search by keyword or date")
    
        
        .overlay {
            if searchedWorkouts.isEmpty && searchQuery.isEmpty == false  {
                ContentUnavailableView {
                    Label("No results", systemImage: "magnifyingglass")
                        .padding()
                    
                    Text("Check the spelling or try a new search.")
                        .font(.subheadline)
                }
                
            } else if searchedWorkouts.isEmpty {
                ContentUnavailableView {
                    Label(filterType == "All" ? "No workouts found": "\(filterType) workouts weren't found :( ", systemImage: "note")
                        .padding()
                } actions: {
                    Button {
                        showingAddWorkout.toggle()
                    } label: {
                        Label("Add a new workout", systemImage: "plus.square")
                    }
                }
            }
        }
        
        

        
        
        
        
        
    } // var Body Bracket
    
    init(filterType: String, sortOrder: [SortDescriptor<Workout>], showingCompletedOnly: Bool, date: Date, darkMode: Bool, selectedTab: Binding<String>, selectedTabString: String, showingCompleted: Binding<Bool>, showingLapsed: Binding<Bool>, showingUpcoming: Binding<Bool>, workoutTypes: [String], disableButton: Binding<Bool>, searchQuery: Binding<String>, showingAddWorkout: Binding<Bool>, editingWorkout: Binding<Bool>, showDeleted: Binding<Bool>, showCompleted: Binding<Bool>, showIncomplete: Binding<Bool>) {
        
        self.darkMode = darkMode
        self.workoutTypes = workoutTypes
        self.filterType = filterType
        self.selectedTabString = selectedTabString

        _selectedTab = selectedTab
        _showingCompleted = showingCompleted
        _showingUpcoming = showingUpcoming
        _showingLapsed = showingLapsed
        _editButtonDisabled = disableButton
        _searchQuery = searchQuery
        _showingAddWorkout = showingAddWorkout
        _editingWorkout = editingWorkout
        _showDeleted = showDeleted
        _showCompleted = showCompleted
        _showIncomplete = showIncomplete

        
        // switch to this
        
        if filterType == "All" {
            switch selectedTabString {
            case "Completed":
                _workouts = Query(filter: #Predicate<Workout> { workout in
                    (workout.inNoFilter == true) && (workout.date <= date) && (workout.isCompleted == true)
                }, sort: sortOrder)
            case "Upcoming":
                _workouts = Query(filter: #Predicate<Workout> { workout in
                    (workout.inNoFilter == true) && (workout.date > date) && (workout.isCompleted == false)
                }, sort: sortOrder)
            case "Lapsed":
                _workouts = Query(filter: #Predicate<Workout> { workout in
                    (workout.inNoFilter == true) && (workout.date <= date) && (workout.isCompleted == false)
                }, sort: sortOrder)
            default:
                _workouts = Query(filter: #Predicate<Workout> { workout in
                    (workout.inNoFilter == true) && (workout.date <= date) && (workout.isCompleted == true)
                }, sort: sortOrder)
            }
        } else if filterType != "All" {
            switch selectedTabString {
            case "Completed":
                _workouts = Query(filter: #Predicate<Workout> { workout in
                    (workout.workoutType.contains(filterType)) &&
                    (workout.date <= date) && (workout.isCompleted == true)
                }, sort: sortOrder)
            case "Lapsed":
                _workouts = Query(filter: #Predicate<Workout> { workout in
                    (workout.workoutType.contains(filterType)) && (workout.date <= date) && (workout.isCompleted == false)
                }, sort: sortOrder)
            default:
                _workouts = Query(filter: #Predicate<Workout> { workout in
                    (workout.workoutType.contains(filterType)) && (workout.date > date) && (workout.isCompleted == false)
                }, sort: sortOrder)
            }
        }

        
//        if filterType == "All" &&  selectedTab == "Past Workouts" {
//            _workouts = Query(filter: #Predicate<Workout> { workout in
//                (workout.inNoFilter == true) && (workout.date <= date) && (workout.isCompleted == true)
//            }, sort: sortOrder)
//        } else if filterType == "All" && selectedTab == "Upcoming" {
//            _workouts = Query(filter: #Predicate<Workout> { workout in
//                (workout.inNoFilter == true) && (workout.date > date) && (workout.isCompleted == false)
//            }, sort: sortOrder)
//        } else if filterType == "All" && selectedTab == "Lapsed" {
//            _workouts = Query(filter: #Predicate<Workout> { workout in
//                (workout.inNoFilter == true) && (workout.date <= date) && (workout.isCompleted == false)
//            }, sort: sortOrder)
//        } else if filterType != "All" && selectedTab == "Past Workouts" {
//            _workouts = Query(filter: #Predicate<Workout> { workout in
//                (workout.workoutType.contains(filterType)) &&
//                (workout.date <= date) && (workout.isCompleted == true)
//            }, sort: sortOrder)
//        } else if filterType != "All" && selectedTab == "Lapsed" {
//            _workouts = Query(filter: #Predicate<Workout> { workout in
//                (workout.workoutType.contains(filterType)) && (workout.date <= date) && (workout.isCompleted == false)
//            }, sort: sortOrder)
//        } else {
//            _workouts = Query(filter: #Predicate<Workout> { workout in
//                (workout.workoutType.contains(filterType)) && (workout.date > date) && (workout.isCompleted == false)
//            }, sort: sortOrder)
//        }
    
    } // Initializer Bracket
    

    
    func deleteWorkout(at offsets: IndexSet) {
        for offset in offsets {
            let workout = workouts[offset]
            modelContext.delete(workout)
        }
    }
    
    func deleteSingleWorkout(workout: Workout) {
        modelContext.delete(workout)
    }
    
    
        
} // WorkoutsView Struct Bracket





struct WorkoutsView2: View {
    var workout: Workout
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    
    var workoutTypes: [String]
    var darkMode: Bool
    @Binding var editingWorkout: Bool
    
    // For deleting
    @State private var showingDeleteAlert = false
    @Binding var showDeleted: Bool
    
    // For Favouriting
    
    // where should this originate too?
    
    @State private var markAsFavouriteAlert = false
    @State private var unmarkAsFavouriteAlert = false
    
    // For marking as complete/incomplete
    
    // where should this originate??
    @State private var markAsCompletedAlert = false
    @State private var markAsIncompleteAlert = false
    
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    
    
    var body: some View {
        NavigationLink {
            WorkoutView(workout: workout, selectedTab: selectedTab, workoutTypes: workoutTypes, darkMode: darkMode, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
        } label: {
            WorkoutsViewHStack(workout: workout, darkMode: darkMode)
        } // Label Bracket
        
        .modifier(SwipeActionsAndAlertsModifiers(workout: workout, showingDeleteAlert: $showingDeleteAlert, showDeleted: $showDeleted, editingWorkout: $editingWorkout, markAsFavouriteAlert: $markAsFavouriteAlert, unmarkAsFavouriteAlert: $unmarkAsFavouriteAlert, selectedTab: selectedTab, markAsCompletedAlert: $markAsCompletedAlert, markAsIncompleteAlert: $markAsIncompleteAlert, showCompleted: $showCompleted, showIncomplete: $showIncomplete))
        
        .fullScreenCover(isPresented: $editingWorkout) {
            EditWorkoutView(workout: workout, workoutTypes: workoutTypes, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, darkMode: darkMode)
        }
        
        
    } // body bracket
} // WorkoutsView 2 bracket
