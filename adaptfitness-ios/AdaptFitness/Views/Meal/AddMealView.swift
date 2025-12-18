//
//  AddMealView.swift
//
//  Created by AI Assistant
//

import SwiftUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedMealType: MealType?
    @State private var mealTime = Date()
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var fiber = ""
    @State private var sugar = ""
    @State private var sodium = ""
    @State private var errorMessage: String?
    @State private var isSaving = false
    
    let onMealAdded: (Meal) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Details")) {
                    TextField("Meal Name", text: $name)
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Meal Type", selection: $selectedMealType) {
                        Text("Select Type").tag(nil as MealType?)
                        ForEach(MealType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }.tag(type as MealType?)
                        }
                    }
                    
                    DatePicker("Meal Time", selection: $mealTime, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Nutrition Information")) {
                    HStack {
                        TextField("Calories", text: $calories)
                            .keyboardType(.numberPad)
                        if !calories.isEmpty {
                            Text("kcal")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Protein", text: $protein)
                            .keyboardType(.decimalPad)
                        if !protein.isEmpty {
                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Carbs", text: $carbs)
                            .keyboardType(.decimalPad)
                        if !carbs.isEmpty {
                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Fat", text: $fat)
                            .keyboardType(.decimalPad)
                        if !fat.isEmpty {
                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Additional Nutrients (Optional)")) {
                    HStack {
                        TextField("Fiber", text: $fiber)
                            .keyboardType(.decimalPad)
                        if !fiber.isEmpty {
                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Sugar", text: $sugar)
                            .keyboardType(.decimalPad)
                        if !sugar.isEmpty {
                            Text("g")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Sodium", text: $sodium)
                            .keyboardType(.decimalPad)
                        if !sodium.isEmpty {
                            Text("mg")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Error message section
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveMeal()
                        }
                        .disabled(name.isEmpty || calories.isEmpty)
                    }
                }
            }
        }
    }
    
    private func saveMeal() {
        guard !name.isEmpty,
              !calories.isEmpty,
              let authToken = authManager.authToken else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let formatter = ISO8601DateFormatter()
        
        let mealRequest = CreateMealRequest(
            name: name,
            description: description.isEmpty ? nil : description,
            mealTime: formatter.string(from: mealTime),
            totalCalories: Double(calories) ?? 0,
            mealType: selectedMealType?.rawValue,
            totalProtein: protein.isEmpty ? nil : Double(protein),
            totalCarbs: carbs.isEmpty ? nil : Double(carbs),
            totalFat: fat.isEmpty ? nil : Double(fat),
            totalFiber: fiber.isEmpty ? nil : Double(fiber),
            totalSugar: sugar.isEmpty ? nil : Double(sugar),
            totalSodium: sodium.isEmpty ? nil : Double(sodium),
            servingSize: nil,
            servingUnit: nil
        )
        
        Task {
            do {
                let newMeal = try await APIService.shared.createMeal(mealRequest, token: authToken)
                await MainActor.run {
                    isSaving = false
                    onMealAdded(newMeal)
                    dismiss()
                }
            } catch let error as APIError {
                await MainActor.run {
                    isSaving = false
                    switch error {
                    case .httpError(401, _):
                        // Token expired or invalid - clear auth state
                        authManager.handleTokenExpiration()
                        errorMessage = "Your session has expired. Please log in again."
                    case .httpError(let code, let message):
                        errorMessage = message ?? "Failed to create meal (code: \(code))"
                    case .unauthorized:
                        authManager.handleTokenExpiration()
                        errorMessage = "Not authenticated. Please log in."
                    default:
                        errorMessage = "Failed to create meal: \(error.localizedDescription)"
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    let errorString = error.localizedDescription
                    if errorString.contains("401") || errorString.contains("Unauthorized") {
                        authManager.handleTokenExpiration()
                        errorMessage = "Your session has expired. Please log in again."
                    } else {
                        errorMessage = "Failed to create meal: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

#Preview {
    AddMealView { _ in }
}
