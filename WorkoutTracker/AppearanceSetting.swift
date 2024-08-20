//
//  AppearanceSetting.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 19/7/24.
//

import Foundation
import SwiftUI
import SwiftData

struct AppearanceSetting: View {
    @Binding var darkMode: Bool // still need to fix how to get default value to control darkMode boolean
    @Binding var selectedMode: String
    
    let modes = ["System", "Dark", "Light"]

    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        // Appearance
        List {
            ForEach(modes, id: \.self) { mode in
                HStack {
                    Text(mode)
                    Spacer()
                    if selectedMode == mode {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedMode = mode
                    if selectedMode == "Dark" {
                        darkMode = true
                    } else if selectedMode == "Light" {
                        darkMode = false
                    } else {
                        colorScheme == .dark ? (darkMode = true) : (darkMode = false)
                    }
                }
                
                
            } // For Each bracket
            
        }
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Appearance")
            }
        }
        
        .navigationBarTitleDisplayMode(.inline)
        
        
        
    }
}
