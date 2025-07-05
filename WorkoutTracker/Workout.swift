import Foundation
import SwiftData

@Model
class Workout: Identifiable, Hashable {
    var id = UUID()
    var workoutDescription: String = ""
    var workoutType: String = ""
    var location: String = ""
    var date: Date = Date.now
    var isCompleted: Bool = false
    var favourites: Bool = false
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
    }
    
    var formattedDateDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: date)
    }
    
    init(id: UUID = UUID(), workoutDescription: String, workoutType: String, location: String, date: Date, isCompleted: Bool, favourites: Bool) {
        self.id = id
        self.workoutDescription = workoutDescription
        self.workoutType = workoutType
        self.location = location
        self.date = date
        self.isCompleted = isCompleted
        self.favourites = favourites
    }
}
