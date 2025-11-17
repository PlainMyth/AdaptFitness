//
//  NutritionDonutChart.swift
//  AdaptFitness
//

import SwiftUI

struct NutritionDonutChart: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    
    private var totalMacros: Double {
        protein + carbs + fat
    }
    
    private var proteinPercentage: Double {
        guard totalMacros > 0 else { return 0 }
        return (protein / totalMacros) * 100
    }
    
    private var carbsPercentage: Double {
        guard totalMacros > 0 else { return 0 }
        return (carbs / totalMacros) * 100
    }
    
    private var fatPercentage: Double {
        guard totalMacros > 0 else { return 0 }
        return (fat / totalMacros) * 100
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let lineWidth: CGFloat = size * 0.15
            let _ = (size - lineWidth) / 2 // radius - unused but kept for clarity
            
            ZStack {
                // Protein (orange/brown)
                Circle()
                    .trim(from: 0, to: proteinPercentage / 100)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                
                // Carbs (green/yellow)
                Circle()
                    .trim(from: proteinPercentage / 100, to: (proteinPercentage + carbsPercentage) / 100)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                
                // Fat (red)
                Circle()
                    .trim(from: (proteinPercentage + carbsPercentage) / 100, to: 1.0)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                
                // Center text showing percentages
                VStack(spacing: 2) {
                    Text(String(format: "%.1f%%", proteinPercentage))
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f%%", carbsPercentage))
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(String(format: "%.1f%%", fatPercentage))
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

// Alternative simpler version with just one percentage
struct SimpleDonutChart: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    let lineWidth: CGFloat
    
    init(progress: Double, color: Color = .blue, lineWidth: CGFloat = 15) {
        self.progress = max(0, min(1, progress)) // Clamp between 0 and 1
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let _ = (size - lineWidth) / 2 // radius - unused but kept for clarity
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                
                // Center percentage
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(color)
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        NutritionDonutChart(protein: 32, carbs: 19, fat: 12)
            .frame(width: 150, height: 150)
        
        SimpleDonutChart(progress: 0.75, color: .blue)
            .frame(width: 100, height: 100)
    }
    .padding()
}

