//
//  AddWorkoutForm.swift
//  AdaptFitness
//
//  Created by csuftitan on 10/10/25.
//
import SwiftUI

struct AddWorkoutForm: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var duration = ""
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout name", text: $name)
                    TextField("Duration (minutes)", text: $duration)
                        .keyboardType(.numberPad)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Add Workout")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save logic here
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
