//
//  AdaptFitnessApp.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/15/25.
//

import SwiftUI
import SwiftData

@main
struct AdaptFitnessApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // Show HomePageView first (matches main branch structure)
            // HomePageView uses FooterTabBar for navigation, not standard TabView
            HomePageView(
                isLoggedIn: .constant(true),
                user: User.exampleUser
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
