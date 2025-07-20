import Foundation
import SwiftUI
import SwiftData

struct SwipeActionsAndAlertsModifiers: ViewModifier {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var workout: Workout
    
    // For Deleting
    @Binding var showingDeleteAlert: Bool
    @Binding var showDeleted: Bool
    
    // For Editing ?
    @Binding var editingWorkout: Bool
    
    // For Favouriting
    @Binding var markAsFavouriteAlert: Bool
    @Binding var unmarkAsFavouriteAlert: Bool

    // For complete
    var selectedTab: String
    @Binding var markAsCompletedAlert: Bool
    @Binding var markAsIncompleteAlert: Bool
    
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    
    func body(content: Content) -> some View {
        content
            // delete
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    showingDeleteAlert.toggle()
                } label: {
                    Image("icons8-delete-darkmode")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .scaledToFit()
                        .tint(.red)
                }
            }
            
            .alert("Delete Workout", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(workout)
                    showDeleted.toggle()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this workout permanently?")
            }
            
            // favourite + completed
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                // Favouriting
                Button {
                    if workout.favourites == false {
                        markAsFavouriteAlert.toggle()
                    } else {
                        unmarkAsFavouriteAlert.toggle()
                    }
                    
                    
                } label: { //
                    workout.favourites == false ?
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 5, height: 5)
                        .scaledToFit()
                        .tint(.yellow) :
                    
                    Image(systemName: "heart.slash.fill") // padding of 60%
                        .resizable()
                        .frame(width: 5, height: 5)
                        .scaledToFit()
                        .tint(.yellow)
                    
                }
                
                
                // Completion
                if selectedTab == "Completed" || selectedTab == "Lapsed" || selectedTab == "Settings" {
                    Button {
                    
//                        workout.isCompleted.toggle()
                        
                        if workout.isCompleted {
                            markAsIncompleteAlert.toggle()
                        } else {
                            markAsCompletedAlert.toggle()
                        }
                        
                        
    //                    dismiss()
                        
                        
                    } label: {
                        if workout.isCompleted == true {
                            Image(systemName: "bookmark.slash")
                                .tint(.gray)
                        } else {
                            Image(systemName: "bookmark" )
                                .tint(.gray)
                        }
                    }
                    
                }
                
            }
        
            .alert("Mark as Favourite", isPresented: $markAsFavouriteAlert) {
                Button("Mark as Favourite", action: { workout.favourites = true })
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Mark this workout as a Favourite?")
            }
            
            .alert("Unmark as Favourite", isPresented: $unmarkAsFavouriteAlert) {
                Button("Unmark as Favourite", action: { workout.favourites = false })
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Unmark this workout as a Favourite?")
            }
        
            .alert("Mark as Completed", isPresented: $markAsCompletedAlert) {
                Button("Mark as Completed", action: {
                    workout.isCompleted = true
                    showCompleted.toggle()
                })
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Mark this workout as Completed?")
            }
        
            .alert("Mark as Incomplete", isPresented: $markAsIncompleteAlert) {
                Button("Mark as Incomplete", action: {
                    workout.isCompleted = false
                    showIncomplete.toggle()
                })
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Mark this workout as Incomplete?")
            }
        
    }
}
