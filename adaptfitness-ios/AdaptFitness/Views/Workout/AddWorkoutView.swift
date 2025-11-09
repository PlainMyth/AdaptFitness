//
//  AddWorkoutView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager()
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedWorkoutType: WorkoutType?
    @State private var startTime = Date()
    @State private var endTime: Date?
    @State private var calories = ""
    @State private var duration = ""
    @State private var sets = ""
    @State private var reps = ""
    @State private var weight = ""
    @State private var isCompleted = true
    
    let onWorkoutAdded: (Workout) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $name)
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Workout Type", selection: $selectedWorkoutType) {
                        Text("Select Type").tag(nil as WorkoutType?)
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }.tag(type as WorkoutType?)
                        }
                    }
                }
                
                Section(header: Text("Timing")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("Set End Time", isOn: Binding(
                        get: { endTime != nil },
                        set: { if $0 { endTime = Date() } else { endTime = nil } }
                    ))
                    
                    if endTime != nil {
                        DatePicker("End Time", selection: Binding(
                            get: { endTime ?? Date() },
                            set: { endTime = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section(header: Text("Metrics")) {
                    HStack {
                        TextField("Duration (minutes)", text: $duration)
                            .keyboardType(.numberPad)
                        if !duration.isEmpty {
                            Text("min")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Calories Burned", text: $calories)
                            .keyboardType(.numberPad)
                        if !calories.isEmpty {
                            Text("cal")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Sets", text: $sets)
                            .keyboardType(.numberPad)
                        TextField("Reps", text: $reps)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        if !weight.isEmpty {
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Toggle("Mark as Completed", isOn: $isCompleted)
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveWorkout() {
        guard !name.isEmpty,
              let authToken = authManager.authToken else { return }
        
        let formatter = ISO8601DateFormatter()
        
        let workoutRequest = CreateWorkoutRequest(
            name: name,
            description: description.isEmpty ? nil : description,
            startTime: formatter.string(from: startTime),
            endTime: endTime != nil ? formatter.string(from: endTime!) : nil,
            totalCaloriesBurned: Double(calories) ?? 0,
            totalDuration: Double(duration) ?? 0,
            totalSets: Double(sets) ?? 0,
            totalReps: Double(reps) ?? 0,
            totalWeight: Double(weight) ?? 0,
            workoutType: selectedWorkoutType,
            isCompleted: isCompleted
        )
        
        Task {
            do {
                let newWorkout = try await APIService.shared.createWorkout(workoutRequest, token: authToken)
                await MainActor.run {
                    onWorkoutAdded(newWorkout)
                    dismiss()
                }
            } catch {
                print("Failed to create workout: \(error)")
                // Handle error
            }
        }
    }
}

#Preview {
    AddWorkoutView { _ in }
}
