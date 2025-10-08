//
//  Main.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/17/25.
//

import SwiftUI

struct HomePageView: View {
    @Binding var isLoggedIn: Bool
    let calendar = Calendar.current
    @State private var days: [Day] = []
    
//    hardcoded data used to mimic returned request
    public var streak: Int = 1
    
    // goals
    @State private var goals: [(title: String, progress: Double, color: Color, icon: String)] = [
            ("Workout Streak", 0.75, .green, "flame.fill"),
            ("Calories", 0.60, .orange, "bolt.heart"),
            ("Steps", 0.90, .blue, "figure.walk"),
            ("Sleep", 0.45, .purple, "bed.double.fill")
        ]
    
    
    
    var body: some View {
        VStack {
            // Header with streak
            HStack {
                Spacer()
                
                // Streak badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill") // fire icon
                        .foregroundColor(.orange)
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("\(streak)") // hardcoded streak number
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 2)
            }
            
            Spacer().frame(height: 20)
            
            // Donut Graphs (placeholders)
//            HStack(spacing: 20) {
//                DonutStat(label: "Walking", value: "4.2 km left")
//                DonutStat(label: "Jan Avg", value: "1199 cal")
//                DonutStat(label: "Stretching", value: "16 left")
//                DonutStat(label: "Workout Days", value: "3 left")
//            }
            
            // Hor Calendar
            HStack(spacing: 10) {
                // where calendarview thing would go
                HorizontalCalendar(days: days)
                    .onAppear {
                        let calendar = Calendar.current
                        let mockCompletedDates: [Date] = [
                            calendar.date(byAdding: .day, value: -2, to: Date())!,
                            calendar.date(byAdding: .day, value: 1, to: Date())!,
                            Date()
                        ]
                        days = generateCurrentWeek(completedWorkouts:mockCompletedDates)
                    }
            }
            
            Text("Goals")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 40) {
                    ForEach(Array(goals.enumerated()), id: \.offset) { index, goal in
                        GoalTileView(
                            progress: goal.progress,
                            color: goal.color,
                            title: goal.title,
                            icon: goal.icon
                        )
                    }
                }
                .padding(.horizontal)
            }
//            spacing color
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            
//            intended color
//            .background(Color(.systemBackground).ignoresSafeArea())
            .onAppear {
                // Example: Simulate progress updates after data fetch
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        goals[0].progress = 0.9
                        goals[1].progress = 0.7
                    }
                }
            }
    
            // Goals
//            VStack {
//                Text("Your goals")
//                    .font(.title2)
//                    .padding(.top, 30)
//                
//                Button(action: {
//                    print("Add new goal tapped")
//                }) {
//                    Text("Add new")
//                        .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(.bordered)
//                .padding(.horizontal)
//            }
            
            // Entries
            ScrollView {
                VStack(spacing: 20) {
                    EntryRow(date: "01/01", images: ["garbanzo", "garbanzo2", "garbanzo3"])
                    EntryRow(date: "01/02", images: ["chicken", "chicken2", "chicken3"])
                }
                .padding(.top, 20)
            }
            
            // Footer Tabs
            FooterTabBar()
            
        }
    }
}

struct DonutStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Circle()
                .strokeBorder(Color.gray, lineWidth: 5)
                .frame(width: 70, height: 70)
            
            VStack {
                Text(label)
                    .font(.caption)
                Text(value)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EntryRow: View {
    let date: String
    let images: [String]
    
    var body: some View {
        HStack {
            Text(date)
                .font(.headline)
                .frame(width: 60)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(image) // must be in Assets.xcassets
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// Preview
struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(isLoggedIn: .constant(true))
    }
}
