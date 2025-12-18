//
//  NotificationsSettingsView.swift
//  AdaptFitness
//
//  Notifications Settings View
//

import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutReminders = true
    @State private var mealReminders = true
    @State private var goalReminders = true
    @State private var streakReminders = true
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Reminders")) {
                    Toggle(isOn: $workoutReminders) {
                        HStack {
                            Image(systemName: "figure.run")
                                .foregroundColor(.blue)
                            Text("Workout Reminders")
                        }
                    }
                    .accessibilityLabel("Workout Reminders")
                    .accessibilityHint("Toggle workout reminder notifications")
                    
                    Toggle(isOn: $mealReminders) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.orange)
                            Text("Meal Logging Reminders")
                        }
                    }
                    .accessibilityLabel("Meal Logging Reminders")
                    .accessibilityHint("Toggle meal logging reminder notifications")
                    
                    Toggle(isOn: $goalReminders) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.green)
                            Text("Goal Progress Updates")
                        }
                    }
                    .accessibilityLabel("Goal Progress Updates")
                    .accessibilityHint("Toggle goal progress update notifications")
                    
                    Toggle(isOn: $streakReminders) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                            Text("Streak Notifications")
                        }
                    }
                    .accessibilityLabel("Streak Notifications")
                    .accessibilityHint("Toggle streak notification reminders")
                }
                
                Section(header: Text("About")) {
                    Text("Notification preferences are saved locally on your device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Dismiss notifications settings")
                }
            }
        }
    }
}

#Preview {
    NotificationsSettingsView()
}

