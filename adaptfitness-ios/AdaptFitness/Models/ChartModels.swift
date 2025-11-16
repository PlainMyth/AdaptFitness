//
//  ChartModels.swift
//  AdaptFitness
//
//  Shared models for chart data visualization
//

import Foundation

/// Data point for calorie charts (burned or consumed)
struct CalorieDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
}

