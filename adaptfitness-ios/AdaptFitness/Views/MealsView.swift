//
//  MealsView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/14/25.
//
import SwiftUI

struct MealsView: View {
    let meals: [Meal]
    
    var body: some View {
        let grouped = meals.groupedByDayDescending()
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(grouped, id: \.day) { day, dayMeals in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DateFormatter.localizedString(from: day, dateStyle: .medium, timeStyle: .none))
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(dayMeals) { meal in
                                    // TODO: Display correct information for each day and probably group them by
                                    // breakfast, lunch and dinner
                                    ForEach(meal.foods) { food in
                                        EntryRow(
                                            date: meal.dayLabel, // optional
                                            foods: [food.name] // or food.image if you have images
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
