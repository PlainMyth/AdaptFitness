//
//  AddGoalFormView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/7/25.
//
// TODO: This form is not correct
import SwiftUI

struct AddGoalForm: View {
    @Binding var goals: [Goal] // ✅ Updated to use [Goal]
    @State private var goalType = ""
    @State private var goalAmount = ""
    @State private var goalUnits = ""
    @State private var window = ""
    @State private var icon = "figure.walk" // Default SF Symbol

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Type (e.g. Activity, Nutrition)", text: $goalType)
                    TextField("Goal Amount", text: $goalAmount)
                        .keyboardType(.decimalPad)
                    TextField("Goal Units (e.g. steps, lbs, calories)", text: $goalUnits)
                    TextField("Window (e.g. weekly, monthly)", text: $window)
                }
                
                Section(header: Text("Icon")) {
                    TextField("SF Symbol Name", text: $icon)
                    Text("Preview:")
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
                
                Button(action: addGoal) {
                    Label("Add Goal", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Add Goal")
        }
    }
    
    // Function to create and append a new Goal
    private func addGoal() {
        let newGoal = Goal(
            id: UUID().uuidString,
            type: goalType.isEmpty ? "Activity" : goalType,
            goalAmount: Double(goalAmount) ?? 0,
            goalUnits: goalUnits.isEmpty ? "steps" : goalUnits,
            window: window.isEmpty ? "weekly" : window,
            icon: icon,
            progress: 0.0
        )
        goals.append(newGoal)
        
        // Reset form fields
        goalType = ""
        goalAmount = ""
        goalUnits = ""
        window = ""
        icon = "figure.walk"
    }
}
