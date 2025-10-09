//
//  GoalTileView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/7/25.
//

import SwiftUI

struct GoalTileView: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: progress)

                VStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20))
                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .frame(width: 80, height: 80)
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
        }
        .padding(.vertical, 10)
        .frame(width: 200, height: 180)
    }
}
