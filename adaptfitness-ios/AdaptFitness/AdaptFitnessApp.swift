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
    @State private var isLoggedIn: Bool = true
    
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
            if isLoggedIn {
                HomePageView(isLoggedIn: $isLoggedIn, user: .exampleUser)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
//            HomePageView(isLoggedIn: $isLoggedIn, user: .exampleUser)
        }
        .modelContainer(sharedModelContainer)
    }
}
