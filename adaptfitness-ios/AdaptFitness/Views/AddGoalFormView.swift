//
//  AddGoalFormView.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/7/25.
//
import SwiftUI

struct AddGoalForm: View {
    @Environment(\.dismiss) var dismiss
    @Binding var goals: [(title: String, progress: Double, color: Color, icon: String)]

    @State private var title = ""
    @State private var progress: Double = 0.0
    @State private var color: Color = .green
    @State private var icon: String = "star.fill"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Title", text: $title)

                    HStack {
                        Text("Progress")
                        Slider(value: $progress, in: 0...1)
                        Text("\(Int(progress * 100))%")
                            .frame(width: 50)
                    }

                    ColorPicker("Color", selection: $color)
                    TextField("SF Symbol (icon)", text: $icon)
                }
            }
            .navigationTitle("Add Goal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        goals.append((title: title, progress: progress, color: color, icon: icon))
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
