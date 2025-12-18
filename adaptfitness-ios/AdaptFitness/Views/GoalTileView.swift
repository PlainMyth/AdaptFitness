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

    // Clamp progress between 0 and 1
    private var progressRatio: Double {
        min(max(goal.completionFraction, 0), 1)
    }

    var body: some View {
        HStack(spacing: 12) {
            // MARK: Progress Ring
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

                    Text("\(Int(goal.completionPercentageDouble))%")
                        .font(.headline)
                }
            }
            .frame(width: 80, height: 80)

            // MARK: Goal Info
            VStack(alignment: .leading, spacing: 6) {
                // Description or goal type name
                Text(goal.description ?? goal.goalTypeEnum?.displayName ?? "Unknown Goal")
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Target
                Text("Target: \(Int(goal.targetValueDouble)) \(goal.goalTypeEnum?.unit ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Optional workout type
                if let workoutType = goal.workoutTypeEnum {
                    Text("Workout: \(workoutType.displayName)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                // Progress bar
                ProgressView(value: progressRatio)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .frame(height: 6)
                    .cornerRadius(3)

                // Active / Inactive
                Text(goal.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(goal.isActive ? .green : .gray)
            }
            .padding(.vertical, 4)
        }
        .padding()
        .frame(width: 280, height: 140)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

