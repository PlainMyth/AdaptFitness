//
//  EntryRowView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/14/25.
//
import SwiftUI

struct EntryRow: View {
    let date: String
    let foods: [FoodEntry]  // Array of food names

    var body: some View {
        HStack(alignment: .top) {
//            Text(date)
//                .font(.headline)
//                .frame(width: 100, alignment: .leading)
//                .padding(.leading, 8)
//            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(foods) { food in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(food.name)
                                .font(.subheadline)
                                .bold()
                            Text("\(Int(food.nutrients.calories)) kcal")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 120, height: 60, alignment: .leading)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}


