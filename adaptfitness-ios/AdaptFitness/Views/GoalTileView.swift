//
//  GoalTileView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/7/25.
//

import SwiftUI

struct GoalTileView: View {
    let goal: GoalCalendar
    let color: Color

    // Safely clamp progress between 0 and 1
    private var progressRatio: Double {
        min(max(goal.completionFraction, 0), 1)
    }

    var body: some View {
        HStack(spacing: 12) {

            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progressRatio)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: progressRatio)

                VStack(spacing: 4) {
                    Image(systemName: goal.goalTypeEnum?.icon ?? "questionmark.circle")
                        .foregroundColor(color)
                        .font(.system(size: 18))

                    Text("\(Int(goal.completionPercentage))%")
                        .font(.headline)
                }
            }
            .frame(width: 80, height: 80)

            // Goal Info
            VStack(alignment: .leading, spacing: 6) {
                Text(goal.goalTypeEnum?.displayName ?? "questionmark.circle")
                    .font(.headline)

                Text("Target: \(Int(goal.targetValue)) \(goal.goalTypeEnum?.unit ?? "questionmark.circle")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let workoutType = goal.workoutType {
                    Text("Workout: \(goal.goalTypeEnum?.displayName ?? "questionmark.circle")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(goal.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(goal.isActive ? .green : .gray)
            }
        }
        .padding(.vertical, 10)
        .frame(width: 260, height: 120)
    }
}
