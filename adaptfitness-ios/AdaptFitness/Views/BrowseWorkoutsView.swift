//
//  BrowseView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/17/25.
//

import SwiftUI

//struct Workout: Identifiable {
//    let id = UUID()
//    let name: String
//    let intensity: String
//    let calories: String
//    let systemImage: String
//}

struct BrowseWorkoutsView: View {
    
    let workouts: [Workout] = [
        Workout(name: "Add Custom Workout", intensity: "", calories: "", systemImage: "plus.circle"),
        Workout(name: "Running", intensity: "High", calories: "352 per 30 min", systemImage: "figure.run"),
        Workout(name: "Walking", intensity: "Low", calories: "150 per 30 min", systemImage: "figure.walk"),
        Workout(name: "Swimming", intensity: "High", calories: "215 per 30 min", systemImage: "drop.fill"),
        Workout(name: "Cycling", intensity: "Low-High", calories: "225 per 30 min", systemImage: "bicycle"),
        Workout(name: "Hiking", intensity: "Low-Moderate", calories: "180 per 30 min", systemImage: "figure.hiking"),
        Workout(name: "Yoga", intensity: "Low-High", calories: "173 per 30 min", systemImage: "figure.cooldown"),
        Workout(name: "Boxing", intensity: "High", calories: "400 per 30 min", systemImage: "figure.boxing")
    ]
    
    var body: some View {
        VStack {
            // Header
            Text("Browse Workouts")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
           
            // Exit & Favorites Buttons
            HStack {
                Button(action: {
                    print("Exit tapped")
                }) {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                }
                
                Spacer()
                
                Button(action: {
                    print("Favorite tapped")
                }) {
                    Image(systemName: "star.fill")
                        .font(.title)
                }
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(workouts) { workout in
                        WorkoutTile(workout: workout)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Footer buttons
            FooterTabBar()
        }
    }
}

struct WorkoutTile: View {
    let workout: Workout
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: workout.systemImage)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .padding()
            
            Text(workout.name)
                .font(.headline)
            
            if !workout.intensity.isEmpty {
                Text("Intensity: \(workout.intensity)")
                    .font(.subheadline)
            }
            if !workout.calories.isEmpty {
                Text("Est Cal: \(workout.calories)")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    BrowseWorkoutsView()
}
