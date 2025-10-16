//
//  EntryRowView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/14/25.
//
import SwiftUI

struct EntryRow: View {
    let date: String
    let foods: [String]  // Array of food names

    var body: some View {
        HStack(alignment: .top) {
            Text(date)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
                .padding(.leading, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(foods, id: \.self) { foodName in
                        Text(foodName)
                            .font(.subheadline)
                            .frame(width: 100, height: 50)
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


