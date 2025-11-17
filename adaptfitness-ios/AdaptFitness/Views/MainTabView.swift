//
//  MainTabView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            // Goals Tab
            GoalCalendarView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            // Workouts Tab
            WorkoutListView()
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                    Text("Workouts")
                }
            
            // Meals Tab
            MealListView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Meals")
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
}
