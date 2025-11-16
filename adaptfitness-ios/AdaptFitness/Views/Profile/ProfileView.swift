//
//  ProfileView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/15/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showingLogin = false
    @State private var showingHealthMetrics = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if authManager.isAuthenticated, let user = authManager.currentUser {
                    // MARK: - User Header Section
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
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // MARK: - Settings Menu Section
                    List {
                        // Settings Section
                        Section(header: Text("Settings")) {
                            // Health Metrics / Nutrition
                            Button(action: {
                                showingHealthMetrics = true
                            }) {
                                HStack {
                                    Image(systemName: "heart.text.square.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Health Metrics")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("BMI, TDEE, Body Composition")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            
                            // Account Settings (placeholder for future features)
                            Button(action: {
                                // TODO: Add account settings view
                            }) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Account Settings")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Edit profile, preferences")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            
                            // Notifications (placeholder for future features)
                            Button(action: {
                                // TODO: Add notifications settings view
                            }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Notifications")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Manage alerts and reminders")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            
                            // Privacy & Security (placeholder for future features)
                            Button(action: {
                                // TODO: Add privacy settings view
                            }) {
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Privacy & Security")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text("Data privacy, security settings")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Account Actions Section
                        Section(header: Text("Account")) {
                            Button(action: {
                                authManager.logout()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.square.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                        .frame(width: 30)
                                    
                                    Text("Log Out")
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    // MARK: - Not Logged In State
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Not Logged In")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Log in to sync your data with the backend")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Log In") {
                            showingLogin = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingLogin) {
                LoginView()
            }
            .sheet(isPresented: $showingHealthMetrics) {
                HealthMetricsView()
            }
        }
    }
}

#Preview {
    ProfileView()
}
