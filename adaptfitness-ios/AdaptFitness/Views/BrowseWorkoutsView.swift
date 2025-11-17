//
//  BrowseView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/17/25.
//

import SwiftUI

struct BrowseWorkoutsView: View {
    @State private var selectedTab: FooterTabBar.Tab = .browse
    
    let workoutTemplates: [WorkoutTemplate] = [
        WorkoutTemplate(name: "Add Custom Workout", intensity: "", calories: "", systemImage: "plus.circle"),
        WorkoutTemplate(name: "Running", intensity: "High", calories: "352 per 30 min", systemImage: "figure.run"),
        WorkoutTemplate(name: "Walking", intensity: "Low", calories: "150 per 30 min", systemImage: "figure.walk"),
        WorkoutTemplate(name: "Swimming", intensity: "High", calories: "215 per 30 min", systemImage: "drop.fill"),
        WorkoutTemplate(name: "Cycling", intensity: "Low-High", calories: "225 per 30 min", systemImage: "bicycle"),
        WorkoutTemplate(name: "Hiking", intensity: "Low-Moderate", calories: "180 per 30 min", systemImage: "figure.hiking"),
        WorkoutTemplate(name: "Yoga", intensity: "Low-High", calories: "173 per 30 min", systemImage: "figure.cooldown"),
        WorkoutTemplate(name: "Boxing", intensity: "High", calories: "400 per 30 min", systemImage: "figure.boxing")
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
                    ForEach(workoutTemplates) { template in
                        WorkoutTemplateTile(template: template)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Footer buttons
            FooterTabBar(selectedTab: $selectedTab)
        }
    }
}

struct WorkoutTemplateTile: View {
    let template: WorkoutTemplate
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: template.systemImage)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .padding()
            
            Text(template.name)
                .font(.headline)
            
            if !template.intensity.isEmpty {
                Text("Intensity: \(template.intensity)")
                    .font(.subheadline)
            }
            if !template.calories.isEmpty {
                Text("Est Cal: \(template.calories)")
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
