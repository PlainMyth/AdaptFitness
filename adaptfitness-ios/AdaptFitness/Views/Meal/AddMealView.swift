//
//  AddMealView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    
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
                    Button("Save") {
                        saveMeal()
                    }
                    .disabled(name.isEmpty || calories.isEmpty)
                }
            }
        }
    }
    
    private func saveMeal() {
        guard !name.isEmpty,
              !calories.isEmpty else { return }
        
        let formatter = ISO8601DateFormatter()
        
        let mealRequest = CreateMealRequest(
            name: name,
            description: description.isEmpty ? nil : description,
            mealTime: formatter.string(from: mealTime),
            totalCalories: Double(calories) ?? 0,
            totalProtein: protein.isEmpty ? nil : Double(protein),
            totalCarbs: carbs.isEmpty ? nil : Double(carbs),
            totalFat: fat.isEmpty ? nil : Double(fat),
            totalFiber: fiber.isEmpty ? nil : Double(fiber),
            totalSugar: sugar.isEmpty ? nil : Double(sugar),
            totalSodium: sodium.isEmpty ? nil : Double(sodium),
            mealType: selectedMealType,
            servingSize: nil,
            servingUnit: nil
        )
        
        Task {
            do {
                // Use the new APIService.request() method
                // The new Core/Network/APIService handles auth automatically via KeychainManager
                let apiService = APIService.shared
                let newMeal: Meal = try await apiService.request(
                    endpoint: "/meals",
                    method: .post,
                    body: mealRequest,
                    requiresAuth: true
                )
                await MainActor.run {
                    onMealAdded(newMeal)
                    dismiss()
                }
            } catch {
                print("Failed to create meal: \(error)")
                // Handle error
            }
        }
    }
}

#Preview {
    AddMealView { _ in }
}
