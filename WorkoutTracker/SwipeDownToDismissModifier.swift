//
//  SwipeDownToDismissModifier.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 25/7/24.
//

import Foundation
import SwiftUI

struct SwipeDownToDismissModifier: ViewModifier {
    @Binding var showingAddWorkout: Bool
    @Environment(\.dismiss) var dismiss
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.height > 100 && abs(value.translation.width) < 20 {
                            withAnimation {
                                dismiss()
                                showingAddWorkout = false
                            }
                        }
                    }
            
            
            )
    }
}

extension View {
    func swipeDownToDismiss(showingAddWorkout: Binding<Bool>) -> some View {
        self.modifier(SwipeDownToDismissModifier(showingAddWorkout: showingAddWorkout))
    }
}
