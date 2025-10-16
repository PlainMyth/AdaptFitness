//
//  ProfileView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/15/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Log Out") {
                        authManager.logout()
                    }
                    .foregroundColor(.red)
                    .padding()
                } else {
                    Text("Loading...")
                        .font(.title2)
                }
            }
            .navigationTitle("Profile")
            .padding()
        }
    }
}

#Preview {
    ProfileView()
}
