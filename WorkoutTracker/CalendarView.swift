import Foundation
import SwiftUI
import SwiftData

struct CalendarView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    @Query var workouts: [Workout]
    
    var date: Date
    // gives Date.now. You want to use this to initialise the view, then be able to move back and forth between views
    
    @Binding var editButtonDisabled: Bool
    @Binding var showingAddWorkout: Bool
    
    @Binding var editingWorkout: Bool
    var darkMode: Bool
    @Binding var selectedTab: String
    var selectedTabString: String
    
    // Passed the below in so that WorkoutView can be called
    @Binding var showingCompleted: Bool
    @Binding var showingLapsed: Bool
    @Binding var showingUpcoming: Bool
    
    var workoutTypes: [String]
    
    @State private var showingDeleteAlert = false
    @Binding var showDeleted: Bool
    @Binding var showAdded: Bool
    
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
    
    // For completed alert
    @Binding var showCompleted: Bool
    @Binding var showIncomplete: Bool
    
    // GPT-suggested variables
    private let calendar = Calendar.current
    @State private var month: Date = .now
    
    // Optional variable to keep track of the date that user clicks into
    @State private var selectedDate: Date?
    
    // Boolean that keeps track of whether to open DayDetailView.
    @State private var showingDetail: Bool = false
    
    // to compute Grid of dates for current month
    @State private var daysInMonth: [Date] = []
    
    private func updateDays() {
      guard let interval = calendar.dateInterval(of: .month, for: month),
            let first = calendar.date(from: calendar.dateComponents([.year, .month], from: interval.start))
      else { return }
      let shift = calendar.component(.weekday, from: first) - calendar.firstWeekday
      let start = calendar.date(byAdding: .day, value: -shift, to: first)!
      daysInMonth = (0..<42).map { calendar.date(byAdding: .day, value: $0, to: start)! }
    }
    
    // New variables for dragging down
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    
    // For dot indicator
    @State private var workoutsByDay: [Date: [Workout]] = [:]
    
    private func rebuildIndex() {
        workoutsByDay = Dictionary(
            grouping: workouts,
            by: { calendar.startOfDay(for: $0.date) }
          )
    }
    
    @ViewBuilder
    private func detailPanel(for date: Date) -> some View {
        // 1. look up that day's workouts once
        let dayKey = calendar.startOfDay(for: date)
        let todaysWorkouts = workoutsByDay[dayKey] ?? []
        
        // Empty‐state vs. real detail
        if todaysWorkouts.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.secondary)
                Text("No workouts found")
                    .font(.headline)
                Button {
                    showingAddWorkout = true
                } label: {
                    Label("Add a workout", systemImage: "plus.app")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(.systemBackground))
        } else {
            DayDetailView(
                date: date,
                workoutsForDay: todaysWorkouts,
                darkMode: darkMode,
                selectedTab: $selectedTab,
                showingCompleted: $showingCompleted,
                showingLapsed: $showingLapsed,
                showingUpcoming: $showingUpcoming,
                workoutTypes: workoutTypes,
                showingDetail: $showingDetail,
                showAdded: $showAdded,
                showDeleted: $showDeleted,
                showCompleted: $showCompleted,
                showIncomplete: $showIncomplete
            )
        }
        
    }
    
    var body: some View {
        let cellHeight: CGFloat = 50
        VStack(spacing: 5) {
            // Month Navigation Buttons
            ZStack {
                HStack {
                    Button { month = calendar.date(byAdding: .month, value: -1, to: month) ?? month } label: { Image(systemName: "chevron.left") }
                    Spacer()
                    
                    Button { month = calendar.date(byAdding: .month, value: 1, to: month) ?? month } label: { Image(systemName: "chevron.right") }
                }
                
                Text(month, formatter: Self.monthFormatter)
                    .font(.title2)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            // "S M T W T F S"
            HStack(spacing: 12) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day.prefix(1))
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Dates
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12 ) {
                ForEach(daysInMonth, id: \.self) { date in
                    let dayNumber = calendar.component(.day, from: date)
                    let isSelected = selectedDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false
                    let isThisDate = calendar.startOfDay(for: date)
                    let hasWorkout = (workoutsByDay[isThisDate]?.isEmpty == false)
                    
                    Button {
                        selectedDate = date
                        showingDetail = true
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                if isSelected {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 36, height: 36)
                                } else if isToday(date) {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                }
                                
                                Text("\(dayNumber)")
                                  .font(.body.weight(isSelected ? .bold : .regular))
                                  .foregroundColor(
                                    isSelected
                                      ? .white
                                      : (isThisMonth(date) ? .primary : .secondary)
                                  )
                                
                            } // ZStack
                            .frame(width: 36, height: 36)
                            
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 4, height: 4)
                                .opacity(hasWorkout ? 1 : 0)
                        
                        }
                        .frame(maxWidth: .infinity, minHeight: cellHeight, alignment: .top)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
            
            
            if showingDetail, let date = selectedDate {
                detailPanel(for: date)
                    .padding(.horizontal)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showingDetail)
            }

            
        } // VStack
        .onAppear{ 
            updateDays()
            rebuildIndex()
        }
        .onChange(of: month) {
            updateDays()
        }
        .onChange(of: workouts) {
            rebuildIndex()
        }
        
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    
    private func isThisMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    
    private static var monthFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        return df
    }
    
}


