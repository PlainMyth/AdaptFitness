//
//  GoalTileView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/7/25.
//

import SwiftUI

struct GoalTileView: View {
    let goal: Goal
    // TODO: Implement different colored rings
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: goal.progress / goal.goalAmount)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: goal.progress)

                VStack {
                    Image(systemName: goal.icon)
                        .foregroundColor(color)
                        .font(.system(size: 20))
                    Text("\(Int(goal.progress / goal.goalAmount * 100))%")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(goal.type.capitalized)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(Int(goal.progress))/")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(Int(goal.goalAmount)) \(goal.goalUnits)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Window: \(goal.window.capitalized)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 10)
        .frame(width: 250, height: 120)
    }
}

