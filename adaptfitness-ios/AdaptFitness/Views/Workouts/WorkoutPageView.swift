//
//  WorkoutPageView.swift
//  AdaptFitness
//
//  Workout page showing workout history and calories consumed chart
//

import SwiftUI
import Charts
import Foundation

struct WorkoutPageView: View {
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var mealViewModel = MealViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Time Range Selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedTimeRange) { oldValue, newValue in
                        Task {
                            await workoutViewModel.fetchWorkouts()
                            mealViewModel.loadMeals()
                        }
                    }
                    
                    // MARK: - Calories Consumed Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calories Consumed")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        if !filteredMealData.isEmpty {
                            Chart(filteredMealData) { data in
                                LineMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Calories", data.calories)
                                )
                                .foregroundStyle(.blue)
                                .interpolationMethod(.catmullRom)
                                
                                AreaMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Calories", data.calories)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month().day())
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            emptyChartView(message: "No meal data available")
                        }
                    }
                    
                    // MARK: - Workout History
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Workout History")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(filteredWorkouts.count) workouts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if !filteredWorkouts.isEmpty {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredWorkouts) { workout in
                                    WorkoutHistoryRow(workout: workout)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            emptyStateView(message: "No workouts yet", icon: "figure.run")
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Workouts")
            .task {
                await workoutViewModel.fetchWorkouts()
                mealViewModel.loadMeals()
            }
            .refreshable {
                await workoutViewModel.fetchWorkouts()
                mealViewModel.loadMeals()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredWorkouts: [WorkoutResponse] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return workoutViewModel.workouts.filter { workout in
            // workout.startTime is already a Date, not a String
            return workout.startTime >= startDate
        }
    }
    
    private var filteredMealData: [CalorieDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        let filteredMeals = mealViewModel.meals.filter { meal in
            if let mealDate = meal.date {
                return mealDate >= startDate
            }
            return false
        }
        
        let grouped = Dictionary(grouping: filteredMeals) { meal -> Date in
            if let mealDate = meal.date {
                return calendar.startOfDay(for: mealDate)
            }
            return calendar.startOfDay(for: Date())
        }
        
        return grouped.map { date, meals in
            let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
            return CalorieDataPoint(date: date, calories: totalCalories)
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper Methods
    
    private func emptyChartView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func emptyStateView(message: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    WorkoutPageView()
}

