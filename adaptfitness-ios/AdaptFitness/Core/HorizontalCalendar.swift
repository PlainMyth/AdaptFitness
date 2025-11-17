//
//  HorizontalCalendar.swift
//  AdaptFitness
//
//  Horizontal calendar component for displaying days of the week
//

import SwiftUI

struct Day: Identifiable {
    let id = UUID()
    let date: Date
    let isCompleted: Bool
    let dayName: String
    let dayNumber: String
}

struct HorizontalCalendar: View {
    let days: [Day]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(days) { day in
                    VStack(spacing: 5) {
                        Text(day.dayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(day.dayNumber)
                            .font(.headline)
                            .foregroundColor(day.isCompleted ? .green : .primary)
                        Circle()
                            .fill(day.isCompleted ? Color.green : Color.clear)
                            .frame(width: 8, height: 8)
                    }
                    .frame(width: 50)
                    .padding(.vertical, 10)
                    .background(day.isCompleted ? Color.green.opacity(0.1) : Color.clear)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
}

func generateCurrentWeek(completedWorkouts: [Date]) -> [Day] {
    let calendar = Calendar.current
    let today = Date()
    
    // Get Monday of current week
    let weekday = calendar.component(.weekday, from: today)
    let daysFromMonday = (weekday + 5) % 7 // Convert Sunday=1 to Monday=0
    guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
        return []
    }
    
    var days: [Day] = []
    let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    for i in 0..<7 {
        guard let date = calendar.date(byAdding: .day, value: i, to: monday) else { continue }
        
        let dayNumber = calendar.component(.day, from: date)
        let dayName = dayNames[i]
        
        // Check if this date has a completed workout
        let isCompleted = completedWorkouts.contains { workoutDate in
            calendar.isDate(workoutDate, inSameDayAs: date)
        }
        
        days.append(Day(
            date: date,
            isCompleted: isCompleted,
            dayName: dayName,
            dayNumber: String(dayNumber)
        ))
    }
    
    return days
}

