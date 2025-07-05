import SwiftUI
import SwiftData
import Foundation

// Hex's of colours used in the app
// white is FFFFFF
// black is 000000
// gray is 808080
// padding at 20%

struct ContentView: View {
    // selectedTab can be "Past Workouts", "Lapsed", "Upcoming", "Calendar" or "Settings"
    
    @State private var selectedTab = "Completed"

    // These variables keep track of which tab is being opened. Should be toggled whenever
    
    @State private var showingCompleted = true
    @State private var showingLapsed = false
    @State private var showingUpcoming = false
    @State private var showingCalendar = false
    @State private var showingSettings = false
    
    
    // Want to be able to pick diff sort orders for diff tabs too
    @State private var sortOrder = [
        SortDescriptor(\Workout.date, order: .reverse),
        SortDescriptor(\Workout.workoutType),
    ]
    
    // Filter Type Tracking
    
    @State private var filterTypeCompleted = "All"
    
    @State private var filterTypeLapsed = "All"
    
    @State private var filterTypeUpcoming = "All"
    
    @State var disabledEditButton: Bool = false
    
    
    // For full screen cover
    @State private var showingAddWorkout = false
    @State private var editingWorkout = false
    
    // Want to be able to allow user to edit workout types too in the settings tab
    @State var workoutTypes = ["Run", "Walk", "Gym", "Swim", "Cycle", "Yoga"]
    @State var suggestedWorkoutTypes = ["Football", "Basketball", "Bouldering", "Pilates", "Spin", "Calisthenics"]
    
    var itemsKey = "itemsKey"
    var itemsKey2 = "itemsKey2"
     
    // For Settings Tab
    @Environment(\.colorScheme) var colorScheme
    @State private var darkMode = true
    
    // For adding, deleting, favouriting and completed alerts.
    // Purely decorative, not essential to functionality.
    
    @State private var showAdded = false
    @State private var animateAddedCircle = false
    
    @State private var showDeleted = false
    @State private var animateDeletedCircle = false
    
    @State private var showFavourited = false
    @State private var animatedFavouritedCircle = false
    
    @State private var showCompleted = false
    @State private var animateCompletedCircle = false
    
    @State private var showIncomplete = false
    @State private var animateIncompleteCircle = false
    
    // For Search bar
    @State private var searchQuery = ""

    var body: some View {
        switch selectedTab {
        case "Completed":
            NavigationStack {
            
                VStack {
                    if filterTypeCompleted != "All" {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.secondary)
                                .frame(minWidth: 80, idealWidth: 90, maxWidth: 350, minHeight: 35, idealHeight: 35, maxHeight: 35)
                                .opacity(0.8)
                            //                                    .padding(.leading, 10)
                            //                                .padding(5)
                            
                            HStack(spacing: 8) {
                                Text(filterTypeCompleted)
                                    .padding(.leading, 15)
                                
                                Button {
                                    filterTypeCompleted = "All"
                                } label: {
                                    Image(darkMode ? "icons8-close-outlined-darkmode": "icons8-close-outlined-lightmode" )
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .scaledToFit()
                                }
                                
                                Spacer()
                            }
                        }.fixedSize()
                        
                    } // if bracket for filterTypeCompleted != "All"
                    
                    ZStack {
                        WorkoutsView(filterType: filterTypeCompleted, sortOrder: sortOrder, showingCompletedOnly: showingCompleted, date: Date.now, darkMode: darkMode, selectedTab: $selectedTab, selectedTabString: selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, disableButton: $disabledEditButton, searchQuery: $searchQuery, showingAddWorkout: $showingAddWorkout, editingWorkout: $editingWorkout, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
                        
                            .navigationBarTitleDisplayMode(.inline)
                        
                            .toolbar {
                                ToolbarItemGroup(placement: .topBarLeading) {
                                    Menu(content: {
                                        Picker("Sort", selection: $filterTypeCompleted) {
                                            ForEach(["All"] + workoutTypes, id: \.self) {
                                                Text("\($0) Workouts")
                                                    .monospaced()
                                            }
                                        }
                                    }, label: {
                                        Image(darkMode ? "icons8-funnel-100-darkmode": "icons8-funnel-100-lightmode")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .scaledToFit()
                                    })
                                    
                                }
                                
                                ToolbarItemGroup(placement: .principal) {
                                    Text("Completed")
                                        .font(.title3)
                                        .padding(20)
                                }
                                
                                ToolbarItemGroup(placement: .topBarTrailing) {
                                    Button(action: {
                                        showingAddWorkout.toggle()
                                        //                                selectedTab = "Add Workout"
                                    })  {
                                        Image(darkMode ? "icons8-add-v3-100-darkmode" : "icons8-add-v3-100-lightmode")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .scaledToFit()
                                    }
                                    .monospaced()
                                }
                                
                            } // toolbar closing bracket
                        
                            .fullScreenCover(isPresented: $showingAddWorkout) {
                                AddWorkout(darkMode: darkMode, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showAdded: $showAdded, initialDate: Date.now)
                            }
                        
                            .animation(.smooth, value: filterTypeCompleted)
                        
                        
                        if showAdded {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    
                                    
                                    HStack(spacing: 20) {
                                        Text("Workout Added")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            //                                        Circle().stroke(lineWidth: 1).foregroundStyle(.green)
                                            //                                            .frame(width: 50, height: 50)
                                            //                                            .scaleEffect(animateAddedCircle ? 1.2: 0.90)
                                            //                                            .opacity(animateAddedCircle ? 0 : 1)
                                            //                                            .animation(.easeInOut(duration: 2).delay(0.1).repeatForever(autoreverses: false), value: animateAddedCircle)
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.green)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateAddedCircle ? 1.2: 0.90)
                                                .opacity(animateAddedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateAddedCircle)
                                                .onAppear {
                                                    animateAddedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateAddedCircle.toggle()
                                                }
                                            
                                            Image("icons8-tick-darkmode2")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showAdded = false
                                        }
                                    })
                                }
                                
                                
                                
                            } // VStack
                            //                        .transition(.asymmetric(insertion: .scale, removal: .move(edge: .leading)))
                            //                        .transition(.slide)
                            //                        .transition(.move(edge: .leading))
                            
                        } // if bracket
                        
                        if showDeleted {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    HStack(spacing: 20) {
                                        Text("Workout Deleted")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            
                                            Circle()
                                                .fill(.red)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle()
                                                .stroke(lineWidth: 1)
                                                .foregroundStyle(.red)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateDeletedCircle ? 1.2: 0.90)
                                                .opacity(animateDeletedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2).delay(0.1)/*.repeatForever(autoreverses: true)*/, value: animateDeletedCircle)
                                                .onAppear {
                                                    animateDeletedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateDeletedCircle.toggle()
                                                }
                                            
                                            Image("icons8-delete-darkmode")
                                            
                                            
                                        }
                                        
                                        
                                    }
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showDeleted = false
                                        }
                                    })
                                }
                                
                            }
                            //                        .transition(.move(edge: .leading))
                            //                        .transition(.slide)
                            
                        }
                        
                        if showCompleted {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    
                                    
                                    HStack(spacing: 15) {
                                        Text("Workout Completed")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            Circle()
                                                .fill(.gray)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.secondary)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateCompletedCircle ? 1.2: 0.90)
                                                .opacity(animateCompletedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateCompletedCircle)
                                                .onAppear {
                                                    animateCompletedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateCompletedCircle.toggle()
                                                }
                                            
                                            Image(systemName: "bookmark")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showCompleted = false
                                        }
                                    })
                                }
                                
                                
                                
                            } // VStack
                            
                            
                        } // Outermost ZStack
                        
                        if showIncomplete {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    
                                    
                                    HStack(spacing: 15) {
                                        Text("Workout Incomplete")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            Circle()
                                                .fill(.gray)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.secondary)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateIncompleteCircle ? 1.2: 0.90)
                                                .opacity(animateIncompleteCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateIncompleteCircle)
                                                .onAppear {
                                                    animateIncompleteCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateIncompleteCircle.toggle()
                                                }
                                            
                                            Image(systemName:"bookmark.slash")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showIncomplete = false
                                        }
                                    })
                                }
                                
                                
                                
                            } // VStack
                            
                            
                        }
                    }
                }
                
                BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                
            } // NavigationStack
            .preferredColorScheme(darkMode ? .dark: .light)
            .accentColor(darkMode ? .white: .black)
            .monospaced()
            .onAppear(perform: loadItems)
            
        case "Lapsed":
            NavigationStack {
                VStack {
                    if filterTypeLapsed != "All" {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.secondary)
                                .frame(minWidth: 80, idealWidth: 90, maxWidth: 350, minHeight: 35, idealHeight: 35, maxHeight: 35)
                                .opacity(0.8)
                            
                            HStack(spacing: 8) {
                                Text(filterTypeLapsed)
                                    .padding(.leading, 15)
                                
                                Button {
                                    filterTypeLapsed = "All"
                                } label: {
                                    Image(darkMode ? "icons8-close-outlined-darkmode": "icons8-close-outlined-lightmode" )
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .scaledToFit()
                                }
                                
                                Spacer()
                            }
                        }.fixedSize()

                    }
                    
                    
                    // if bracket for filterTypeLapsed != "All"
                    
                    ZStack {
                        
                        WorkoutsView(filterType: filterTypeLapsed, sortOrder: sortOrder, showingCompletedOnly: showingCompleted, date: Date.now, darkMode: darkMode, selectedTab: $selectedTab, selectedTabString: selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, disableButton: $disabledEditButton, searchQuery: $searchQuery, showingAddWorkout: $showingAddWorkout, editingWorkout: $editingWorkout, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
                        
                            .navigationBarTitleDisplayMode(.inline)
                        
                            .toolbar {
                                ToolbarItemGroup(placement: .topBarLeading) {
                                    Menu(content: {
                                        Picker("Sort", selection: $filterTypeLapsed) {
                                            ForEach(["All"] + workoutTypes, id: \.self) {
                                                Text("\($0) Workouts")
                                                    .monospaced()
                                            }
                                        }
                                    }, label: {
                                        Image(darkMode ? "icons8-funnel-100-darkmode": "icons8-funnel-100-lightmode")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .scaledToFit()
                                    })
                                    
                                }
                                
                                ToolbarItemGroup(placement: .principal) {
                                    Text(selectedTab)
                                        .font(.title3)
                                        .padding(20)
                                }
                                
                                ToolbarItemGroup(placement: .topBarTrailing) {
                                    Button(action: {
                                        showingAddWorkout.toggle()
                                    })  {
                                        Image(darkMode ? "icons8-add-v3-100-darkmode" : "icons8-add-v3-100-lightmode")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .scaledToFit()
                                    }
                                    .monospaced()
                                }
                                
                            } // toolbar closing bracket
                        

                            .fullScreenCover(isPresented: $showingAddWorkout) {
                                //            Text("Add Workout")
                                AddWorkout(darkMode: darkMode, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showAdded: $showAdded, initialDate: Date.now)

                            }

                        
                            .animation(.smooth, value: filterTypeLapsed)
                        
                        
                        if showAdded {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()

                                    
                                    
                                    HStack(spacing: 20) {
                                        Text("Workout Added")
                                            .font(.system(size: 15))
                                            .bold()

                                        ZStack {
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.green)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateAddedCircle ? 1.2: 0.90)
                                                .opacity(animateAddedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateAddedCircle)
                                                .onAppear {
                                                    animateAddedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateAddedCircle.toggle()
                                                }
                                            
                                            Image("icons8-tick-darkmode2")

                                        }


                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showAdded = false
                                        }
                                    })
                                }

                                
                                
                            } // VStack

                        } // if bracket
                        
                        if showDeleted {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    HStack(spacing: 20) {
                                        Text("Workout Deleted")
                                            .font(.system(size: 15))
                                            .bold()

                                        ZStack {
                                            
                                            Circle()
                                                .fill(.red)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle()
                                                .stroke(lineWidth: 1)
                                                .foregroundStyle(.red)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateDeletedCircle ? 1.2: 0.90)
                                                .opacity(animateDeletedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2).delay(0.1)/*.repeatForever(autoreverses: true)*/, value: animateDeletedCircle)
                                                .onAppear {
                                                    animateDeletedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateDeletedCircle.toggle()
                                                }
                                            
                                            Image("icons8-delete-darkmode")


                                        }


                                    }
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showDeleted = false
                                        }
                                    })
                                }
                                
                            }

                        }
                        
                        if showCompleted {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    
                                    
                                    HStack(spacing: 15) {
                                        Text("Workout Completed")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            Circle()
                                                .fill(.gray)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.secondary)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateCompletedCircle ? 1.2: 0.90)
                                                .opacity(animateCompletedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateCompletedCircle)
                                                .onAppear {
                                                    animateCompletedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateCompletedCircle.toggle()
                                                }
                                            
                                            Image(systemName: "bookmark")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showCompleted = false
                                        }
                                    })
                                }
                                
                                
                                
                            } // VStack
                            
                            
                        } // Outermost ZStack
                        
                        if showIncomplete {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                    //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    
                                    
                                    HStack(spacing: 15) {
                                        Text("Workout Incomplete")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            Circle()
                                                .fill(.gray)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.secondary)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateIncompleteCircle ? 1.2: 0.90)
                                                .opacity(animateIncompleteCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateIncompleteCircle)
                                                .onAppear {
                                                    animateIncompleteCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateIncompleteCircle.toggle()
                                                }
                                            
                                            Image(systemName:"bookmark.slash")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showIncomplete = false
                                        }
                                    })
                                }
                                
                                
                                
                            } // VStack
                            
                            
                        }
                        
                        
                    }
                }
                
                BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                
                
            } // NavigationStack
            .preferredColorScheme(darkMode ? .dark: .light)
            .accentColor(darkMode ? .white: .black)
            .monospaced()
            .onAppear(perform: loadItems)
            
            
        case "Upcoming":
            NavigationStack {
                VStack {
                    if filterTypeUpcoming != "All" {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.secondary)
                                .frame(minWidth: 80, idealWidth: 90, maxWidth: 350, minHeight: 35, idealHeight: 35, maxHeight: 35)
                                .opacity(0.8)
                            
                            HStack(spacing: 8) {
                                Text(filterTypeUpcoming)
                                    .padding(.leading, 15)
                                
                                Button {
                                    filterTypeUpcoming = "All"
                                } label: {
                                    Image(darkMode ? "icons8-close-outlined-darkmode": "icons8-close-outlined-lightmode" )
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .scaledToFit()
                                }
                                
                                Spacer()
                            }
                        }.fixedSize()
                    }
                    
                    ZStack {
                        WorkoutsView(filterType: filterTypeUpcoming, sortOrder: sortOrder, showingCompletedOnly: showingCompleted, date: Date.now, darkMode: darkMode, selectedTab: $selectedTab, selectedTabString: selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, disableButton: $disabledEditButton, searchQuery: $searchQuery, showingAddWorkout: $showingAddWorkout, editingWorkout: $editingWorkout, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)

                            .navigationBarTitleDisplayMode(.inline)
                            
                            .toolbar {
                                ToolbarItemGroup(placement: .topBarLeading) {
                                    Menu(content: {
                                        Picker("Sort", selection: $filterTypeUpcoming) {
                                            ForEach(["All"] + workoutTypes, id: \.self) {
                                                Text("\($0) Workouts")
                                                    .monospaced()
                                            }
                                        }
                                    }, label: {
                                        Image(darkMode ? "icons8-funnel-100-darkmode": "icons8-funnel-100-lightmode")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .scaledToFit()
                                    })
                                    
                                }
                                
                                ToolbarItemGroup(placement: .principal) {
                                        Text(selectedTab)
                                        .font(.title3)
                                        .padding(20)
                                }

                                ToolbarItemGroup(placement: .topBarTrailing) {
                                    Button(action: {
                                        showingAddWorkout.toggle()
                                 })  {
                                     Image(darkMode ? "icons8-add-v3-100-darkmode" : "icons8-add-v3-100-lightmode")
                                         .resizable()
                                         .frame(width: 28, height: 28)
                                         .scaledToFit()
                                    }
                                    .monospaced()
                                }
                                

                            } // toolbar closing bracket
                        
                            .fullScreenCover(isPresented: $showingAddWorkout) {
                                AddWorkout(darkMode: darkMode, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showAdded: $showAdded, initialDate: Date.now)
                            }
                            
                            .animation(.smooth, value: filterTypeUpcoming)
                        
                        
                // maybe add an animation for change in value of selectedTab?
                        
                        if showAdded {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()

                                    
                                    
                                    HStack(spacing: 20) {
                                        Text("Workout Added")
                                            .font(.system(size: 15))
                                            .bold()

                                        ZStack {
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.green)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateAddedCircle ? 1.2: 0.90)
                                                .opacity(animateAddedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateAddedCircle)
                                                .onAppear {
                                                    animateAddedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateAddedCircle.toggle()
                                                }
                                            
                                            Image("icons8-tick-darkmode2")

                                        }


                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showAdded = false
                                        }
                                    })
                                }

                                
                                
                            } // VStack

                        } // if bracket
                        
                        if showDeleted {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    HStack(spacing: 20) {
                                        Text("Workout Deleted")
                                            .font(.system(size: 15))
                                            .bold()

                                        ZStack {
                                            
                                            Circle()
                                                .fill(.red)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle()
                                                .stroke(lineWidth: 1)
                                                .foregroundStyle(.red)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateDeletedCircle ? 1.2: 0.90)
                                                .opacity(animateDeletedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2).delay(0.1)/*.repeatForever(autoreverses: true)*/, value: animateDeletedCircle)
                                                .onAppear {
                                                    animateDeletedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateDeletedCircle.toggle()
                                                }
                                            
                                            Image("icons8-delete-darkmode")


                                        }


                                    }
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showDeleted = false
                                        }
                                    })
                                }
                                
                            }
                        }
                            
                        if showCompleted {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    
                                    
                                    HStack(spacing: 15) {
                                        Text("Workout Completed")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            Circle()
                                                .fill(.gray)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.secondary)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateCompletedCircle ? 1.2: 0.90)
                                                .opacity(animateCompletedCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateCompletedCircle)
                                                .onAppear {
                                                    animateCompletedCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateCompletedCircle.toggle()
                                                }
                                            
                                            Image(systemName: "bookmark")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showCompleted = false
                                        }
                                    })
                                }
                                
                                
                                
                            } // VStack
                            
                            
                        } // Outermost ZStack
                        
                        if showIncomplete {
                            VStack {
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(darkMode ? .black: .white)
                                        .opacity(1)
                                        .frame(width: 270, height: 80)
                                        .padding()
                                    
                                    
                                    
                                    HStack(spacing: 15) {
                                        Text("Workout Incomplete")
                                            .font(.system(size: 15))
                                            .bold()
                                        
                                        ZStack {
                                            Circle()
                                                .fill(.gray)
                                                .frame(width: 45, height: 45)
                                            
                                            Circle().stroke(lineWidth: 1).foregroundStyle(.secondary)
                                                .frame(width: 50, height: 50)
                                                .scaleEffect(animateIncompleteCircle ? 1.2: 0.90)
                                                .opacity(animateIncompleteCircle ? 0 : 1)
                                                .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateIncompleteCircle)
                                                .onAppear {
                                                    animateIncompleteCircle.toggle()
                                                }
                                                .onDisappear {
                                                    animateIncompleteCircle.toggle()
                                                }
                                            
                                            Image(systemName:"bookmark.slash")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                        withAnimation {
                                            showIncomplete = false
                                        }
                                    })
                                }
                                
                                
                                
                            } // VStack
                        }
                        
                    }
                }
                
                BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                
            } // NavigationStack
            .preferredColorScheme(darkMode ? .dark: .light)
            .accentColor(darkMode ? .white: .black)
            .monospaced()
            .onAppear(perform: loadItems)
            
        case "Calendar":
            NavigationStack {
                VStack {
                    CalendarView(date: Date.now, editButtonDisabled: $disabledEditButton, showingAddWorkout: $showingAddWorkout, editingWorkout: $editingWorkout, darkMode: darkMode, selectedTab: $selectedTab, selectedTabString: selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showDeleted: $showDeleted, showAdded: $showAdded, searchQuery: $searchQuery, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
                        .toolbar {
                            ToolbarItemGroup(placement: .principal) {
                                Text(selectedTab)
                                    .font(.title3)
                                    .padding(20)
                            }
                            
                            ToolbarItemGroup(placement: .topBarTrailing) {
                                Button {
                                    showingAddWorkout.toggle()
                                } label: {
                                    Image(darkMode ? "icons8-add-v3-100-darkmode" : "icons8-add-v3-100-lightmode")
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .scaledToFit()
                                }
                                
                            }
                        }
                        .fullScreenCover(isPresented: $showingAddWorkout) {
                            AddWorkout(darkMode: darkMode, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showAdded: $showAdded, initialDate: Date.now)
                        }
                    
                }
                
                Spacer()
                
                BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                
            } // NavigationStack Bracket
            .preferredColorScheme(darkMode ? .dark: .light)
            .accentColor(darkMode ? .white: .black)
            .monospaced()
            
        case "Settings":
            SettingsView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode, workoutTypes: $workoutTypes, suggestedWorkoutTypes: $suggestedWorkoutTypes)
                
        default:
            NavigationStack {
                    VStack {
                        if filterTypeCompleted != "All" {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.secondary)
                                    .frame(minWidth: 80, idealWidth: 90, maxWidth: 350, minHeight: 35, idealHeight: 35, maxHeight: 35)
                                    .opacity(0.8)
                                
                                HStack(spacing: 8) {
                                    Text(filterTypeCompleted)
                                        .padding(.leading, 15)
                                    
                                    Button {
                                        filterTypeCompleted = "All"
                                    } label: {
                                        Image(darkMode ? "icons8-close-outlined-darkmode": "icons8-close-outlined-lightmode" )
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .scaledToFit()
                                    }
                                    
                                    Spacer()
                                }
                            }.fixedSize()

                        } // if bracket for filterTypeCompleted != "All"
                        
                        ZStack {
                            WorkoutsView(filterType: filterTypeCompleted, sortOrder: sortOrder, showingCompletedOnly: showingCompleted, date: Date.now, darkMode: darkMode, selectedTab: $selectedTab, selectedTabString: selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, disableButton: $disabledEditButton, searchQuery: $searchQuery, showingAddWorkout: $showingAddWorkout, editingWorkout: $editingWorkout, showDeleted: $showDeleted, showCompleted: $showCompleted, showIncomplete: $showIncomplete)
                            
                                .navigationBarTitleDisplayMode(.inline)
                            
                                .toolbar {
                                    ToolbarItemGroup(placement: .topBarLeading) {
                                        Menu(content: {
                                            Picker("Sort", selection: $filterTypeCompleted) {
                                                ForEach(["All"] + workoutTypes, id: \.self) {
                                                    Text("\($0) Workouts")
                                                        .monospaced()
                                                }
                                            }
                                        }, label: {
                                            Image(darkMode ? "icons8-funnel-100-darkmode": "icons8-funnel-100-lightmode")
                                                .resizable()
                                                .frame(width: 28, height: 28)
                                                .scaledToFit()
                                        })
                                        
                                    }
                                    
                                    ToolbarItemGroup(placement: .principal) {
                                        Text("Completed")
                                            .font(.title3)
                                            .padding(20)
                                    }
                                    
                                    ToolbarItemGroup(placement: .topBarTrailing) {
                                        Button(action: {
                                            showingAddWorkout.toggle()
            //                                selectedTab = "Add Workout"
                                        })  {
                                            Image(darkMode ? "icons8-add-v3-100-darkmode" : "icons8-add-v3-100-lightmode")
                                                .resizable()
                                                .frame(width: 28, height: 28)
                                                .scaledToFit()
                                        }
                                        .monospaced()
                                    }
                                    
                                } // toolbar closing bracket
                                
                                .fullScreenCover(isPresented: $showingAddWorkout) {
                                    AddWorkout(darkMode: darkMode, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showAdded: $showAdded, initialDate: Date.now)
                                }
                            
                                .animation(.smooth, value: filterTypeCompleted)
                            
                            
                            if showAdded {
                                VStack {
                                    Spacer()
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(darkMode ? .black: .white)
        //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                            .opacity(1)
                                            .frame(width: 270, height: 80)
                                            .padding()

                                        
                                        
                                        HStack(spacing: 20) {
                                            Text("Workout Added")
                                                .font(.system(size: 15))
                                                .bold()

                                            ZStack {
                                                Circle().stroke(lineWidth: 1).foregroundStyle(.green)
                                                    .frame(width: 50, height: 50)
                                                    .scaleEffect(animateAddedCircle ? 1.2: 0.90)
                                                    .opacity(animateAddedCircle ? 0 : 1)
                                                    .animation(.easeOut(duration: 2.0).delay(0.1) /*.repeatForever(autoreverses: false)*/, value: animateAddedCircle)
                                                    .onAppear {
                                                        animateAddedCircle.toggle()
                                                    }
                                                    .onDisappear {
                                                        animateAddedCircle.toggle()
                                                    }
                                                
                                                Image("icons8-tick-darkmode2")

                                            }


                                        }
                                        
                                        
                                    }
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                            withAnimation {
                                                showAdded = false
                                            }
                                        })
                                    }

                                    
                                    
                                } // VStack

                            } // if bracket
                            
                            if showDeleted {
                                VStack {
                                    Spacer()
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(darkMode ? .black: .white)
        //                                    .stroke(darkMode ? .white: .black, lineWidth: 1)
                                            .opacity(1)
                                            .frame(width: 270, height: 80)
                                            .padding()
                                        
                                        HStack(spacing: 20) {
                                            Text("Workout Deleted")
                                                .font(.system(size: 15))
                                                .bold()

                                            ZStack {
                                                
                                                Circle()
                                                    .fill(.red)
                                                    .frame(width: 45, height: 45)
                                                
                                                Circle()
                                                    .stroke(lineWidth: 1)
                                                    .foregroundStyle(.red)
                                                    .frame(width: 50, height: 50)
                                                    .scaleEffect(animateDeletedCircle ? 1.2: 0.90)
                                                    .opacity(animateDeletedCircle ? 0 : 1)
                                                    .animation(.easeOut(duration: 2).delay(0.1)/*.repeatForever(autoreverses: true)*/, value: animateDeletedCircle)
                                                    .onAppear {
                                                        animateDeletedCircle.toggle()
                                                    }
                                                    .onDisappear {
                                                        animateDeletedCircle.toggle()
                                                    }
                                                
                                                Image("icons8-delete-darkmode")


                                            }


                                        }
                                    }
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                            withAnimation {
                                                showDeleted = false
                                            }
                                        })
                                    }
                                    
                                }

                            }
                            
                            // add more if brackets here for ifFavourtie and ifCompleted
                            
            

                        } // Outermost ZStack
                    }
                                
                BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: $darkMode)
                
            } // NavigationStack
            .preferredColorScheme(darkMode ? .dark: .light)
            .accentColor(darkMode ? .white: .black)
            .monospaced()
            .onAppear(perform: loadItems)
        }
        
    } // Body var Bracket
    
    func loadItems() {
        if let savedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey) as? [String] {
            workoutTypes = savedWorkoutTypes
        }
            
        if let savedSuggestedWorkoutTypes = UserDefaults.standard.array(forKey: itemsKey2) as? [String] {
            suggestedWorkoutTypes = savedSuggestedWorkoutTypes
        }
    }
    
    
} // ContentView Struct Bracket

//
//#Preview {
//    ContentView()
//}

