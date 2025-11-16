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
            
            // MARK: - Health Tab
            // Displays health metrics including BMI, TDEE, RMR, body composition, and measurements
            // Shows all calculated health metrics from the backend API
            // Allows users to add new health metrics entries via form sheet
            HealthMetricsView()
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Health")
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

// ProfileView is defined in Views/Profile/ProfileView.swift
// Removed duplicate definition from here

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
}
