//
//  MealListView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct MealListView: View {
    @StateObject private var viewModel = MealViewModel()
    @State private var showingAddMeal = false
    @State private var selectedMeal: Meal?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading meals...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.meals.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Meals Logged Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start tracking your nutrition by logging your first meal!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Log Meal") {
                            showingAddMeal = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.meals) { meal in
                            MealRowView(meal: meal)
                                .onTapGesture {
                                    selectedMeal = meal
                                }
                        }
                        .onDelete(perform: deleteMeals)
                    }
                }
            }
            .navigationTitle("Meals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddMeal = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealView { newMeal in
                    viewModel.addMeal(newMeal)
                }
            }
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(meal: meal)
            }
        }
        .onAppear {
            viewModel.loadMeals()
        }
    }
    
    private func deleteMeals(offsets: IndexSet) {
        withAnimation {
            viewModel.deleteMeals(at: offsets)
        }
    }
}

struct MealRowView: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: meal.mealType?.icon ?? "fork.knife")
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let description = meal.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(meal.totalCalories)) cal")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    if let protein = meal.totalProtein {
                        Text("\(Int(protein))g protein")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                if let mealType = meal.mealType {
                    Text(mealType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(formatMealTime(meal.mealTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatMealTime(_ timeString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: timeString) else { return timeString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

#Preview {
    MealListView()
}
