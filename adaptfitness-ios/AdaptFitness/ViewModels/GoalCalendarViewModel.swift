//
//  GoalCalendarViewModel.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI
import Combine

@MainActor
class GoalCalendarViewModel: ObservableObject {
    @Published var allGoals: [GoalCalendar] = []
    @Published var currentWeekGoals: [GoalCalendar] = []
    @Published var statistics: GoalStatistics?
    @Published var isLoading = false
    @Published var error: String?
    
    private let authManager = AuthManager.shared
    private let apiService = APIService.shared
    
    func loadGoals() {
        guard let token = authManager.authToken else {
            error = "Not authenticated"
            return
        }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                async let allGoalsTask = apiService.getGoals(token: token)
                async let currentWeekGoalsTask = apiService.getCurrentWeekGoals(token: token)
                async let statisticsTask = apiService.getGoalStatistics(token: token)
                
                let (allGoalsResult, currentWeekGoalsResult, statisticsResult) = await (
                    try allGoalsTask,
                    try currentWeekGoalsTask,
                    try statisticsTask
                )
                
                allGoals = allGoalsResult
                currentWeekGoals = currentWeekGoalsResult
                statistics = statisticsResult
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func refreshGoals() async {
        guard let token = authManager.authToken else {
            error = "Not authenticated"
            return
        }
        
        do {
            // Update progress for all goals
            let updatedGoals = try await apiService.updateGoalProgress(token: token)
            allGoals = updatedGoals
            currentWeekGoals = updatedGoals.filter { goal in
                isGoalInCurrentWeek(goal)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func addGoal(_ goal: GoalCalendar) {
        allGoals.insert(goal, at: 0)
        
        if isGoalInCurrentWeek(goal) {
            currentWeekGoals.insert(goal, at: 0)
        }
    }
    
    private func isGoalInCurrentWeek(_ goal: GoalCalendar) -> Bool {
        let formatter = ISO8601DateFormatter()
        guard let startDate = formatter.date(from: goal.weekStartDate),
              let endDate = formatter.date(from: goal.weekEndDate) else {
            return false
        }
        
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    func getGoalsByType(_ goalType: GoalType) -> [GoalCalendar] {
        return allGoals.filter { $0.goalType == goalType }
    }
    
    func getCompletedGoals() -> [GoalCalendar] {
        return allGoals.filter { $0.isCompleted }
    }
    
    func getActiveGoals() -> [GoalCalendar] {
        return allGoals.filter { $0.isActive }
    }
    
    var averageCompletionRate: Double {
        guard !allGoals.isEmpty else { return 0 }
        return allGoals.reduce(0) { $0 + $1.completionPercentage } / Double(allGoals.count)
    }
    
    var mostCommonGoalType: GoalType? {
        let goalTypeCounts = Dictionary(grouping: allGoals, by: { $0.goalType })
        return goalTypeCounts.max { $0.value.count < $1.value.count }?.key
    }
    
    func getGoalsForWeek(startDate: Date, endDate: Date) -> [GoalCalendar] {
        let formatter = ISO8601DateFormatter()
        
        return allGoals.filter { goal in
            guard let goalStart = formatter.date(from: goal.weekStartDate),
                  let goalEnd = formatter.date(from: goal.weekEndDate) else {
                return false
            }
            
            return (goalStart >= startDate && goalStart <= endDate) ||
                   (goalEnd >= startDate && goalEnd <= endDate) ||
                   (goalStart <= startDate && goalEnd >= endDate)
        }
    }
}
