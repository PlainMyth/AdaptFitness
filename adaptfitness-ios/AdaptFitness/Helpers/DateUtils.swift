//
//  DateUtils.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/1/25.
//

import SwiftUI

struct Day: Identifiable {
    let id = UUID()
    let date: Date
    let isToday: Bool
    let workoutDone: Bool
}

func generateCurrentWeek(completedWorkouts: [Date]) -> [Day] {
    let calendar = Calendar.current
    let today = Date()
    
    guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today) else {
        return []
    }
    
    var days: [Day] = []
    
    for i in 0..<7 {
        if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
            let isToday = calendar.isDate(day, inSameDayAs: today)
            
            // ✅ Check if this day's date is in the completed workouts list
            let workoutDone = completedWorkouts.contains { completedDay in
                calendar.isDate(completedDay, inSameDayAs: day)
            }
            
            days.append(Day(date: day, isToday: isToday, workoutDone: workoutDone))
        }
    }
    return days
}


struct DayView: View {
    let day: Day
    let calendar = Calendar.current
    
    var body: some View {
        let weekday = calendar.component(.weekday, from: day.date)
        let daySymbol = calendar.shortWeekdaySymbols[weekday - 1].prefix(1)
        let dayNumber = calendar.component(.day, from: day.date)
        
        VStack(spacing: 6) {
            Text(daySymbol)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(dayNumber)")
                .font(.headline)
                .foregroundColor(day.isToday ? .black : .gray)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .stroke(
                            day.workoutDone
                                ? Color.green // ✅ Green if workout done
                                : day.isToday ? Color.black : Color.gray.opacity(0.3),
                            lineWidth: 2
                        )
                )
        }
        .padding(.horizontal, 8)
        .onAppear {
            print("Workout done for \(daySymbol): \(day.workoutDone)")
        }
    }
}

    
struct HorizontalCalendar: View {
    let days: [Day]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(days) { day in
                DayView(day: day)
            }
        }
        .padding(.horizontal)
    }
}


