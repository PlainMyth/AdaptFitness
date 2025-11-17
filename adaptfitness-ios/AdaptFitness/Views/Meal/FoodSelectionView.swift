//
//  FoodSelectionView.swift
//  AdaptFitness
//

import SwiftUI

struct FoodSelectionView: View {
    @StateObject private var viewModel = FoodSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFood: SimplifiedFoodItem?
    
    @State private var isSearching: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Chicken Sandwich", text: $viewModel.searchQuery)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                Task {
                                    await viewModel.searchFoods()
                                }
                            }
                            .onChange(of: viewModel.searchQuery) { newValue in
                                // Debounce search - only search after user stops typing for 1 second
                                if newValue.count >= 2 {
                                    Task {
                                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                                        if viewModel.searchQuery == newValue {
                                            await viewModel.searchFoods()
                                        }
                                    }
                                } else {
                                    viewModel.searchResults = []
                                }
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: {
                                viewModel.searchQuery = ""
                                viewModel.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Microphone button
                    Button(action: {
                        // TODO: Implement voice search
                        print("Voice search tapped")
                    }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                            .padding(10)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // Search Results
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if viewModel.searchResults.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Search for foods")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Enter a food name above to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(viewModel.searchResults) { food in
                        FoodSearchResultRow(food: food)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedFood = food
                                dismiss()
                            }
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Food Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
            }
        }
    }
}

struct FoodSearchResultRow: View {
    let food: SimplifiedFoodItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Food image if available
            if let imageUrlString = food.imageUrl,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "fork.knife")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if let brand = food.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let category = food.category {
                    Text(category)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(food.nutritionPer100g.calories)) Cal")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let servingCalories = food.nutritionPerServing?.calories {
                    Text("\(Int(servingCalories)) Cal/serving")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FoodSelectionView(selectedFood: .constant(nil))
}

