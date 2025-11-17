//
//  TrackingView.swift
//  AdaptFitness
//
//  Tracking page showing workout history, calorie burned charts, and nutrition calculations
//

import SwiftUI
import Charts

struct TrackingView: View {
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
                    
                    // MARK: - Calorie Burned Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calories Burned")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        if !filteredWorkoutData.isEmpty {
                            Chart(filteredWorkoutData) { data in
                                LineMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Calories", data.calories)
                                )
                                .foregroundStyle(.orange)
                                .interpolationMethod(.catmullRom)
                                
                                AreaMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Calories", data.calories)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.3), .orange.opacity(0.0)],
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
                            emptyChartView(message: "No workout data available")
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
                                ForEach(filteredWorkouts.prefix(10)) { workout in
                                    WorkoutHistoryRow(workout: workout)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            emptyStateView(message: "No workouts yet", icon: "figure.run")
                        }
                    }
                    
                    // MARK: - Nutrition Calculations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nutrition Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            NutritionStatCard(
                                title: "Total Calories",
                                value: "\(Int(totalCaloriesConsumed))",
                                unit: "kcal",
                                icon: "flame.fill",
                                color: .orange
                            )
                            
                            NutritionStatCard(
                                title: "Total Protein",
                                value: "\(Int(totalProtein))",
                                unit: "g",
                                icon: "leaf.fill",
                                color: .green
                            )
                            
                            NutritionStatCard(
                                title: "Total Carbs",
                                value: "\(Int(totalCarbs))",
                                unit: "g",
                                icon: "circle.grid.cross.fill",
                                color: .blue
                            )
                            
                            NutritionStatCard(
                                title: "Total Fat",
                                value: "\(Int(totalFat))",
                                unit: "g",
                                icon: "drop.fill",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Tracking")
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
    
    private var filteredWorkoutData: [CalorieDataPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredWorkouts) { workout -> Date in
            // workout.startTime is already a Date, not a String
            return calendar.startOfDay(for: workout.startTime)
        }
        
        return grouped.map { date, workouts in
            let totalCalories = workouts.reduce(0) { $0 + ($1.totalCaloriesBurned ?? 0) }
            return CalorieDataPoint(date: date, calories: totalCalories)
        }.sorted { $0.date < $1.date }
    }
    
    private var totalCaloriesConsumed: Double {
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
        
        return mealViewModel.meals
            .filter { meal in
                if let mealDate = meal.date {
                    return mealDate >= startDate
                }
                return false
            }
            .reduce(0) { $0 + $1.totalCalories }
    }
    
    private var totalProtein: Double {
        mealViewModel.meals
            .reduce(0) { $0 + $1.totalProtein }
    }
    
    private var totalCarbs: Double {
        mealViewModel.meals
            .reduce(0) { $0 + $1.totalCarbs }
    }
    
    private var totalFat: Double {
        mealViewModel.meals
            .reduce(0) { $0 + $1.totalFat }
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

// MARK: - Supporting Views

struct WorkoutHistoryRow: View {
    let workout: WorkoutResponse
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                
                if let description = workout.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    if let calories = workout.totalCaloriesBurned {
                        Label("\(Int(calories)) cal", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    if let duration = workout.totalDuration {
                        Label("\(duration) min", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            Text(workout.formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct NutritionStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TrackingView()
}

