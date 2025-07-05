//
//  BottomBarView.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 4/7/24.
//

// Hex's of colours used in the app
// white is FFFFFF
// black is 000000
// gray is 808080


import Foundation
import SwiftUI

struct BottomBarView: View {
    
    // For bottom bar
    @Binding var selectedTab: String
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    @Binding var showingCalendar: Bool
    @Binding var showingSettings: Bool
    
    // Settings for the app
    @Binding var darkMode: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            
            // Completed Button
            Button {
                selectedTab = "Completed"
                showingCompleted = true
                showingLapsed = false
                showingUpcoming = false
                showingCalendar = false
                showingSettings = false
                
            } label: {
                VStack {
                    Image(showingCompleted ? (darkMode ? "icons8-checklist-64-white": "icons8-checklist-64-lightmode-black"): (darkMode ? "icons8-checklist-64-gray": "icons8-checklist-64-lightmode-gray"  ) )
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    
                    
                    Text("Completed")
                        .foregroundStyle(showingCompleted ? (darkMode ? .white: .black) : .gray)
                        .font(.system(size: 10).monospaced())
                }
            }
            
            // Lapsed button
            Button {
                selectedTab = "Lapsed"
                showingCompleted = false
                showingLapsed = true
                showingUpcoming = false
                showingCalendar = false
                showingSettings = false
            } label: {
                VStack {
                    Image(showingLapsed ? (darkMode ? "icons8-time-100-darkmode-white-with2ptstroke": "icons8-time-100-lightmode-black-with2ptstroke"): (darkMode ? "icons8-time-100-darkmode-gray-with2ptstroke": "icons8-time-100-lightmode-gray-with2ptstroke" ) )
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    
                    Text("Lapsed")
                        .foregroundStyle(showingLapsed ? (darkMode ? .white: .black): .gray)
                        .font(.system(size: 10).monospaced())
                }
            }
            
            // Upcoming Button
            
            Button {
                selectedTab = "Upcoming"
                showingCompleted = false
                showingLapsed = false
                showingUpcoming = true
                showingCalendar = false
                showingSettings = false
            } label: {
                VStack {
                    Image(showingUpcoming ? (darkMode ? "icons8-workout-100-white": "icons8-workout-100-lightmode-black"): (darkMode ? "icons8-workout-100-gray": "icons8-workout-100-lightmode-gray"))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    
                    Text("Upcoming")
                        .foregroundStyle(showingUpcoming ? (darkMode ? .white: .black): .gray)
                        .font(.system(size: 10).monospaced())
                }
            }
            
            // Calendar button
            
            Button {
                selectedTab = "Calendar"
                showingCompleted = false
                showingLapsed = false
                showingUpcoming = false
                showingCalendar = true
                showingSettings = false
            } label: {
                VStack {
                    Image(showingCalendar ? (darkMode ? "icons8-calendar-100-darkmode-white": "icons8-calendar-100-lightmode-black"): (darkMode ? "icons8-calendar-100-darkmode-gray": "icons8-calendar-100-lightmode-gray"))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    
                    Text("Calendar")
                        .foregroundStyle(showingCalendar ? (darkMode ? .white: .black): .gray)
                        .font(.system(size: 10).monospaced())
                }
            }
            
            
            // Settings Button
            
            Button {
                selectedTab = "Settings"
                showingCompleted = false
                showingLapsed = false
                showingUpcoming = false
                showingCalendar = false
                showingSettings = true
            } label: {
                VStack {
                    Image(showingSettings ? (darkMode ? "icons8-settings-100-white": "icons8-settings-100-lightmode-black") : (darkMode ? "icons8-settings-100-gray": "icons8-settings-100-lightmode-gray"))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFit()
                    
                    Text("Settings")
                        .foregroundStyle(showingSettings ? (darkMode ? .white: .black): .gray)
                        .font(.system(size: 10).monospaced())
                }
            }
            
        }
        //HStack Bracket
    } // Body Bracket
    
} // Struct Bracket
