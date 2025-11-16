//
//  AddGoalView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager()
    
    @State private var selectedGoalType: GoalType = .workoutsCount
    @State private var targetValue = ""
    @State private var description = ""
    @State private var selectedWorkoutType: WorkoutType?
    @State private var isActive = true
    
    let onGoalAdded: (GoalCalendar) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    Picker("Goal Type", selection: $selectedGoalType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }.tag(type)
                        }
                    }
                    
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    HStack {
                        TextField("Target Value", text: $targetValue)
                            .keyboardType(.decimalPad)
                        Text(selectedGoalType.unit)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Workout Type (Optional)")) {
                    Picker("Specific Workout Type", selection: $selectedWorkoutType) {
                        Text("All Workout Types").tag(nil as WorkoutType?)
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }.tag(type as WorkoutType?)
                        }
                    }
                }
                
                Section {
                    Toggle("Active Goal", isOn: $isActive)
                }
                
                Section(header: Text("Week Range")) {
                    Text("Goal will be set for the current week")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("Set Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(targetValue.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard !targetValue.isEmpty,
              let authToken = authManager.authToken,
              let target = Double(targetValue) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
        
        let formatter = ISO8601DateFormatter()
        
        let goalRequest = CreateGoalRequest(
            weekStartDate: formatter.string(from: startOfWeek),
            weekEndDate: formatter.string(from: endOfWeek),
            goalType: selectedGoalType,
            targetValue: target,
            description: description.isEmpty ? nil : description,
            workoutType: selectedWorkoutType,
            isActive: isActive
        )
        
        Task {
            do {
                let newGoal = try await APIService.shared.createGoal(goalRequest, token: authToken)
                await MainActor.run {
                    onGoalAdded(newGoal)
                    dismiss()
                }
            } catch {
                print("Failed to create goal: \(error)")
                // Handle error
            }
        }
    }
}

#Preview {
    AddGoalView { _ in }
}
