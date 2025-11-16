//
//  GoalCalendarView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct GoalCalendarView: View {
    @StateObject private var viewModel = GoalCalendarViewModel()
    @State private var showingAddGoal = false
    @State private var selectedGoal: GoalCalendar?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading goals...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Current Week Goals Section
                            if !viewModel.currentWeekGoals.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("This Week's Goals")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Button("Add Goal") {
                                            showingAddGoal = true
                                        }
                                        .font(.caption)
                                        .buttonStyle(.bordered)
                                    }
                                    
                                    ForEach(viewModel.currentWeekGoals) { goal in
                                        GoalCardView(goal: goal)
                                            .onTapGesture {
                                                selectedGoal = goal
                                            }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // Statistics Section
                            if let stats = viewModel.statistics {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Goal Statistics")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    HStack(spacing: 16) {
                                        StatisticCard(
                                            title: "Total Goals",
                                            value: "\(stats.totalGoals)",
                                            icon: "target",
                                            color: .blue
                                        )
                                        
                                        StatisticCard(
                                            title: "Completed",
                                            value: "\(stats.completedGoals)",
                                            icon: "checkmark.circle.fill",
                                            color: .green
                                        )
                                        
                                        StatisticCard(
                                            title: "Active",
                                            value: "\(stats.activeGoals)",
                                            icon: "clock.fill",
                                            color: .orange
                                        )
                                        
                                        StatisticCard(
                                            title: "Success Rate",
                                            value: "\(Int(stats.completionRate))%",
                                            icon: "percent",
                                            color: .purple
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // All Goals Section
                            if !viewModel.allGoals.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("All Goals")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    ForEach(viewModel.allGoals.prefix(5)) { goal in
                                        GoalRowView(goal: goal)
                                            .onTapGesture {
                                                selectedGoal = goal
                                            }
                                    }
                                    
                                    if viewModel.allGoals.count > 5 {
                                        Button("View All Goals") {
                                            // Navigate to full goals list
                                        }
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // Empty State
                            if viewModel.currentWeekGoals.isEmpty && viewModel.allGoals.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "target")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    
                                    Text("No Goals Set")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("Set your first fitness goal to start tracking your progress!")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                    
                                    Button("Set Your First Goal") {
                                        showingAddGoal = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGoal = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView { newGoal in
                    viewModel.addGoal(newGoal)
                }
            }
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal)
            }
        }
        .onAppear {
            viewModel.loadGoals()
        }
        .refreshable {
            await viewModel.refreshGoals()
        }
    }
}

struct GoalCardView: View {
    let goal: GoalCalendar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.goalType.icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.description ?? goal.goalType.displayName)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let workoutType = goal.workoutType {
                        Text(workoutType.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(goal.completionPercentage))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                    
                    Text(goal.status.capitalized)
                        .font(.caption)
                        .foregroundColor(progressColor)
                }
            }
            
            // Progress Bar
            ProgressView(value: goal.completionPercentage / 100)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
            
            HStack {
                Text("\(Int(goal.currentValue)) / \(Int(goal.targetValue)) \(goal.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(goal.weekIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var progressColor: Color {
        switch goal.status {
        case "completed", "achieved": return .green
        case "on_track": return .blue
        case "moderate_progress": return .orange
        case "started": return .yellow
        default: return .gray
        }
    }
}

struct GoalRowView: View {
    let goal: GoalCalendar
    
    var body: some View {
        HStack {
            Image(systemName: goal.goalType.icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.description ?? goal.goalType.displayName)
                    .font(.body)
                    .lineLimit(1)
                
                Text("\(Int(goal.currentValue)) / \(Int(goal.targetValue)) \(goal.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(goal.completionPercentage))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(progressColor)
                
                Text(goal.status.capitalized)
                    .font(.caption2)
                    .foregroundColor(progressColor)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var progressColor: Color {
        switch goal.status {
        case "completed", "achieved": return .green
        case "on_track": return .blue
        case "moderate_progress": return .orange
        case "started": return .yellow
        default: return .gray
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview {
    GoalCalendarView()
}
