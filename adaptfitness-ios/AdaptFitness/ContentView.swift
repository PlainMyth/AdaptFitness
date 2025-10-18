//
//  ContentView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Workouts")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .environmentObject(authManager)
    }
}

#Preview {
    ContentView()
}
