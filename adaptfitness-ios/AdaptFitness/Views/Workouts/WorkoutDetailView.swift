//
//  WorkoutDetailView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/15/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    @State private var workoutName: String
    @State private var selectedIntensity: IntensityLevel = .low
    @State private var selectedMode: DurationMode = .manual
    @State private var duration: TimeInterval = 0
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    init(workout: Workout) {
        print("Creating WorkoutDetailView for: \(workout.name)")
        self.workout = workout
        self._workoutName = State(initialValue: workout.name)
        // Ensure all state variables are properly initialized
        self._selectedIntensity = State(initialValue: .low)
        self._selectedMode = State(initialValue: .manual)
        self._duration = State(initialValue: 0)
        self._selectedDate = State(initialValue: Date())
        self._selectedTime = State(initialValue: Date())
        self._isTimerRunning = State(initialValue: false)
        self._timer = State(initialValue: nil)
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Workout Name - Large title at top
            TextField("Workout Name", text: $workoutName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.horizontal, 20)
            
            // Intensity Selector
            Picker("Intensity", selection: $selectedIntensity) {
                ForEach(IntensityLevel.allCases, id: \.self) { intensity in
                    Text(intensity.rawValue.capitalized).tag(intensity)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            
            // Duration Mode Selector
            Picker("Duration Mode", selection: $selectedMode) {
                ForEach(DurationMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
                
            // Timer Display
            if selectedMode == .stopwatch {
                VStack(spacing: 20) {
                    Text(formatTime(duration))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Button(action: toggleTimer) {
                        Text(isTimerRunning ? "Stop" : "Start")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isTimerRunning ? Color.red : Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                // Manual Duration Input - Show timer even in manual mode
                VStack(spacing: 20) {
                    Text(formatTime(duration))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("Duration:")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 30) {
                        Spacer()
                        
                        // Date Picker
                        VStack(spacing: 4) {
                            Text("Date")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        
                        // Time Picker
                        VStack(spacing: 4) {
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
                
            Spacer()
            
            // Estimated Calories
            VStack(spacing: 5) {
                Text("Estimated Calories")
                    .font(.headline)
                
                Text("\(estimatedCalories) kcal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            
            // Save Button
            Button(action: saveWorkout) {
                Text("Save")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .overlay(
            // Custom back button - positioned like reference
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                Spacer()
            }
        )
        .onDisappear {
            stopTimer()
        }
    }
    
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            duration += 0.1
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)
        return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds)
    }
    
    private var estimatedCalories: Int {
        // Simple calorie estimation based on workout type and intensity
        let baseCalories: Int
        switch workout.name.lowercased() {
        case "running":
            baseCalories = 350
        case "walking":
            baseCalories = 150
        case "swimming":
            baseCalories = 400
        case "cycling":
            baseCalories = 300
        case "hiking":
            baseCalories = 250
        case "yoga":
            baseCalories = 120
        case "boxing":
            baseCalories = 450
        default:
            baseCalories = 200
        }
        
        let intensityMultiplier: Double
        switch selectedIntensity {
        case .low:
            intensityMultiplier = 0.7
        case .medium:
            intensityMultiplier = 1.0
        case .high:
            intensityMultiplier = 1.3
        }
        
        let durationMinutes = selectedMode == .stopwatch ? duration / 60 : 30.0 // Default 30 min for manual
        
        return Int(Double(baseCalories) * intensityMultiplier * (durationMinutes / 30.0))
    }
    
    private func saveWorkout() {
        // Here you would save the workout to your backend or local storage
        print("Saving workout: \(workoutName)")
        print("Intensity: \(selectedIntensity.rawValue)")
        print("Duration: \(formatTime(duration))")
        print("Estimated Calories: \(estimatedCalories)")
        
        dismiss()
    }
}

enum IntensityLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum DurationMode: String, CaseIterable {
    case manual = "Manual"
    case stopwatch = "Stopwatch"
}

#Preview {
    // Create a sample Workout for preview
    let sampleWorkout = Workout(
        id: UUID().uuidString,
        name: "Walking",
        description: nil,
        startTime: ISO8601DateFormatter().string(from: Date()),
        endTime: nil,
        totalCaloriesBurned: 150,
        totalDuration: 30,
        totalSets: 0,
        totalReps: 0,
        totalWeight: 0,
        workoutType: .cardio,
        isCompleted: false,
        userId: "preview-user",
        createdAt: ISO8601DateFormatter().string(from: Date()),
        updatedAt: ISO8601DateFormatter().string(from: Date())
    )
    return WorkoutDetailView(workout: sampleWorkout)
}
