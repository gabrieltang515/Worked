//
//  Workout.swift
//  WorkoutTracker
//
//  Created by Rafael Soh on 26/4/24.
//

import Foundation
import SwiftData


@Model
class Workout: Identifiable, Hashable {
    var id = UUID()
    var workoutDescription: String
    var workoutType: String
    var location: String
    var date: Date
    var isCompleted: Bool // just a true or false
    var favourites: Bool // for favourites
    
    // computed property "Shown In Completed"
    
//    var shownInCompleted: Bool {
//        if date <= Date.now && isCompleted {
//            return true
//        }
//        return false
//    }
    
    var inNoFilter = true
    
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var stringDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: date)
    }

    
    var formattedDateMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: date)
//        let formattedDate = date.formatted(date: .abbreviated, time: .omitted)
//        let index = formattedDate.index(formattedDate.startIndex, offsetBy: 3)
//        return String(formattedDate[..<index])
    }
    
    var formattedDateDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: date)
        
//        let formattedDate = date.formatted(date: .abbreviated, time: .omitted)
//        let start = formattedDate.index(formattedDate.startIndex, offsetBy: 4)
//        let end = formattedDate.index(formattedDate.endIndex, offsetBy: -6)
//        let range = start..<end
//        return String(formattedDate[range])
    }
    
    init(id: UUID = UUID(), workoutDescription: String, workoutType: String, location: String, date: Date, isCompleted: Bool, favourites: Bool) {
        self.id = id
        self.workoutDescription = workoutDescription
        self.workoutType = workoutType
        self.location = location
        self.date = date
        self.isCompleted = isCompleted
        self.favourites = favourites
        
//        self.isCompleted = isCompleted
    }
}
