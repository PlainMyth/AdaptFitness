//
//  ExerciseDetailView.swift
//  AdaptFitness
//
//  Detailed view for a single exercise
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: ExercisePlan
    @Environment(\.dismiss) var dismiss

    var displayName: String {
        exercise.exerciseDetails?.name ?? exercise.exerciseName
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Exercise Image
                    if let details = exercise.exerciseDetails, !details.imageUrl.isEmpty {
                        AsyncImage(url: URL(string: details.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .cornerRadius(12)
                    }

                    // Exercise Name and Sets/Reps
                    VStack(alignment: .leading, spacing: 8) {
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 16) {
                            Label("\(exercise.sets) sets", systemImage: "repeat")
                                .font(.subheadline)
                                .foregroundColor(.blue)

                            Label(exercise.reps, systemImage: "number")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }

                    Divider()

                    // Exercise Details (if available)
                    if let details = exercise.exerciseDetails {
                        // Target Muscles
                        if !details.targetMuscles.isEmpty {
                            DetailSection(title: "Target Muscles") {
                                FlowLayout(spacing: 8) {
                                    ForEach(details.targetMuscles, id: \.self) { muscle in
                                        BadgeView(text: muscle, color: .blue)
                                    }
                                }
                            }
                        }

                        // Secondary Muscles
                        if !details.secondaryMuscles.isEmpty {
                            DetailSection(title: "Secondary Muscles") {
                                FlowLayout(spacing: 8) {
                                    ForEach(details.secondaryMuscles, id: \.self) { muscle in
                                        BadgeView(text: muscle, color: .gray)
                                    }
                                }
                            }
                        }

                        // Equipment
                        if !details.equipments.isEmpty {
                            DetailSection(title: "Equipment") {
                                FlowLayout(spacing: 8) {
                                    ForEach(details.equipments, id: \.self) { equipment in
                                        BadgeView(text: equipment, color: .orange)
                                    }
                                }
                            }
                        }

                        // Overview
                        if let overview = details.overview, !overview.isEmpty {
                            DetailSection(title: "Overview") {
                                Text(overview)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Instructions
                        if !details.instructions.isEmpty {
                            DetailSection(title: "Instructions") {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(Array(details.instructions.enumerated()), id: \.offset) { index, instruction in
                                        HStack(alignment: .top, spacing: 12) {
                                            Text("\(index + 1).")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                            Text(instruction)
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }

                        // Exercise Tips
                        if !details.exerciseTips.isEmpty {
                            DetailSection(title: "Tips") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(details.exerciseTips, id: \.self) { tip in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "lightbulb.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                            Text(tip)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }

                        // Video link if available
                        if let videoUrl = details.videoUrl, !videoUrl.isEmpty {
                            Link(destination: URL(string: videoUrl)!) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Watch Video Tutorial")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    } else {
                        // No details available
                        VStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Exercise details not available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding()
            }
            .navigationTitle("Exercise Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            content
        }
    }
}

struct BadgeView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    ExerciseDetailView(
        exercise: ExercisePlan(
            exerciseName: "Push-ups",
            sets: 3,
            reps: "10-12",
            exerciseDetails: ExerciseDetails(
                exerciseId: "1",
                name: "Push-ups",
                imageUrl: "https://example.com/image.jpg",
                videoUrl: "https://example.com/video.mp4",
                bodyParts: ["Upper Body"],
                equipments: ["Body Weight"],
                exerciseType: "Strength",
                targetMuscles: ["Chest", "Triceps"],
                secondaryMuscles: ["Shoulders"],
                keywords: ["push", "press"],
                overview: "A classic upper body exercise",
                instructions: ["Start in plank position", "Lower your body", "Push back up"],
                exerciseTips: ["Keep your core tight", "Don't let your hips sag"],
                variations: ["Diamond push-ups", "Wide push-ups"],
                relatedExerciseIds: []
            ),
            dataSource: "exercisedb_api_detailed",
            matchConfidence: "high",
            matchedExerciseName: "Push-ups",
            searchStrategy: "direct_match"
        )
    )
}
