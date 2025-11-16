//
//  StatCard.swift
//  AdaptFitness
//
//  Reusable card component for displaying statistics/metrics
//

import SwiftUI

/// Reusable card component for displaying statistics and metrics
///
/// This component provides a consistent visual style for displaying
/// health metrics, statistics, and other numerical data throughout the app.
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    StatCard(
        title: "BMI",
        value: "22.5",
        unit: "Normal",
        icon: "figure.stand",
        color: .blue
    )
    .padding()
}

