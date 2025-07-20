import SwiftUI
import SwiftData
import Combine

struct UpcomingView: View {
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    @Binding var showingCalendar: Bool
    @Binding var showingSettings: Bool
    @Binding var showingAddWorkout: Bool
    @Binding var editingWorkout: Bool
    @Binding var disabledEditButton: Bool
    @Binding var searchQuery: String
    @Binding var showAdded: Bool
    @Binding var showDeleted: Bool
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    @Binding var animateAddedCircle: Bool
    @Binding var animateDeletedCircle: Bool
    @Binding var animateCompletedCircle: Bool
    @Binding var animateIncompleteCircle: Bool
    @Binding var filterTypeUpcoming: String
    @Binding var sortOrder: [SortDescriptor<Workout>]
    
    let darkMode: Bool
    let workoutTypes: [String]
    let loadItems: () -> Void
    
    @EnvironmentObject var keyboard: KeyboardResponder
    
    var body: some View {
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
                        }
                    
                        .fullScreenCover(isPresented: $showingAddWorkout) {
                            AddWorkout(darkMode: darkMode, selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, workoutTypes: workoutTypes, showAdded: $showAdded, initialDate: Date.now)
                        }
                    
                        .animation(.smooth, value: filterTypeUpcoming)
                    
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
                                            .animation(.easeOut(duration: 2.0).delay(0.1), value: animateAddedCircle)
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
                                            .animation(.easeOut(duration: 2).delay(0.1), value: animateDeletedCircle)
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
                                            .animation(.easeOut(duration: 2.0).delay(0.1), value: animateCompletedCircle)
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
                                            .animation(.easeOut(duration: 2.0).delay(0.1), value: animateIncompleteCircle)
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
            
            if !keyboard.isKeyboardVisible {
                BottomBarView(selectedTab: $selectedTab, showingCompleted: $showingCompleted, showingLapsed: $showingLapsed, showingUpcoming: $showingUpcoming, showingCalendar: $showingCalendar, showingSettings: $showingSettings, darkMode: .constant(darkMode))
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            
        } 
        .preferredColorScheme(darkMode ? .dark: .light)
        .accentColor(darkMode ? .white: .black)
        .monospaced()
        .onAppear(perform: loadItems)
    }
}
