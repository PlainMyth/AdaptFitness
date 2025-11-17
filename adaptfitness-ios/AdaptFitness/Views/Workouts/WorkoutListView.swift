//
//  WorkoutListView.swift
//  AdaptFitness
//
//  Created by OzzieC8 on 10/16/25.
//

import SwiftUI
import Charts

struct WorkoutListView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @StateObject private var mealViewModel = MealViewModel()
    @State private var showingCreateSheet = false
    @State private var showingError = false
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
                            await viewModel.fetchWorkouts()
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
                    
                    // MARK: - Workout History Section
                    if viewModel.isLoading && viewModel.workouts.isEmpty {
                        ProgressView("Loading workouts...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if viewModel.workouts.isEmpty {
                        emptyStateView
                    } else {
                        workoutHistorySection
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { 
                        Task {
                            await viewModel.refresh()
                            mealViewModel.loadMeals()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateWorkoutView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .task {
                await viewModel.fetchWorkouts()
                await viewModel.fetchCurrentStreak()
                mealViewModel.loadMeals()
            }
            .refreshable {
                await viewModel.fetchWorkouts()
                await viewModel.fetchCurrentStreak()
                mealViewModel.loadMeals()
            }
        }
    }
    
    // MARK: - Workout History Section
    
    private var workoutHistorySection: some View {
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
            
            LazyVStack(spacing: 12) {
                ForEach(filteredWorkouts) { workout in
                    WorkoutRowView(workout: workout)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    try? await viewModel.deleteWorkout(id: workout.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal)
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
        
        return viewModel.workouts.filter { workout in
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
            if let mealTime = meal.mealTime {
                let formatter = ISO8601DateFormatter()
                guard let mealDate = formatter.date(from: mealTime) else { return false }
                return mealDate >= startDate
            } else {
                return meal.date >= startDate
            }
        }
        
        let grouped = Dictionary(grouping: filteredMeals) { meal -> Date in
            if let mealTime = meal.mealTime {
                let formatter = ISO8601DateFormatter()
                if let date = formatter.date(from: mealTime) {
                    return calendar.startOfDay(for: date)
                }
            }
            return calendar.startOfDay(for: meal.date)
        }
        
        return grouped.map { date, meals in
            let totalCalories = meals.reduce(0) { $0 + ($1.totalCalories ?? 0) }
            return CalorieDataPoint(date: date, calories: totalCalories)
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper Methods
    
    private func parseDate(from dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
    
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
    
    // MARK: - Streak Section
    
    private var streakSection: some View {
        Section {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(viewModel.currentStreak)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(viewModel.currentStreak == 1 ? "day" : "days")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if viewModel.currentStreak > 0 {
                    VStack(spacing: 2) {
                        Image(systemName: streakIcon)
                            .font(.title)
                            .foregroundColor(streakColor)
                        Text(streakMessage)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var streakIcon: String {
        switch viewModel.currentStreak {
        case 0:
            return "moon.zzz.fill"
        case 1...6:
            return "hand.thumbsup.fill"
        case 7...13:
            return "star.fill"
        case 14...29:
            return "trophy.fill"
        default:
            return "crown.fill"
        }
    }
    
    private var streakColor: Color {
        switch viewModel.currentStreak {
        case 0:
            return .gray
        case 1...6:
            return .blue
        case 7...13:
            return .yellow
        case 14...29:
            return .orange
        default:
            return .purple
        }
    }
    
    private var streakMessage: String {
        switch viewModel.currentStreak {
        case 0:
            return "Start today!"
        case 1...6:
            return "Keep going!"
        case 7...13:
            return "Great job!"
        case 14...29:
            return "Amazing!"
        default:
            return "Champion!"
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run.square.stack")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Workouts Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking your fitness journey by adding your first workout")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingCreateSheet = true }) {
                Label("Add Workout", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
    }
}

// MARK: - Workout Row View

struct WorkoutRowView: View {
    let workout: WorkoutResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                
                Spacer()
                
                Text(workout.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let description = workout.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 16) {
                if workout.totalCaloriesBurned != nil {
                    Label(workout.caloriesDisplay, systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if workout.totalDuration != nil {
                    Label(workout.durationDisplay, systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Create Workout View

struct CreateWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var startTime = Date()
    @State private var calories = ""
    @State private var duration = ""
    @State private var notes = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workout Details") {
                    TextField("Workout Name", text: $name)
                        .autocapitalization(.words)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Time") {
                    DatePicker("Start Time", selection: $startTime)
                }
                
                Section("Metrics") {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        TextField("Calories Burned", text: $calories)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        TextField("Duration (minutes)", text: $duration)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(name.isEmpty || isSubmitting)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isSubmitting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func saveWorkout() {
        isSubmitting = true
        
        let caloriesValue = Double(calories) ?? 0
        let durationValue = Double(duration) ?? 0
        
        Task {
            do {
                try await viewModel.createWorkout(
                    name: name,
                    description: description.isEmpty ? nil : description,
                    startTime: startTime,
                    endTime: nil,
                    totalCaloriesBurned: caloriesValue,
                    totalDuration: durationValue,
                    totalSets: 0,
                    totalReps: 0,
                    totalWeight: 0,
                    workoutType: nil,
                    isCompleted: true
                )
                dismiss()
            } catch let error as NetworkError {
                errorMessage = error.localizedDescription
                showingError = true
                isSubmitting = false
            } catch {
                errorMessage = "Failed to create workout"
                showingError = true
                isSubmitting = false
            }
        }
    }
}

// MARK: - Preview

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
    }
}

