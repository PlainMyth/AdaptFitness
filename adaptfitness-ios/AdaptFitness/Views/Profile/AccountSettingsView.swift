//
//  AccountSettingsView.swift
//  AdaptFitness
//
//  Account Settings View
//

import SwiftUI

struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            List {
                if let user = authManager.currentUser {
                    Section(header: Text("Profile Information")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.fullName)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Name: \(user.fullName)")
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Email: \(user.email)")
                    }
                    
                    Section(header: Text("Account Actions")) {
                        Button(action: {
                            // TODO: Implement edit profile
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                Text("Edit Profile")
                            }
                        }
                        .accessibilityLabel("Edit Profile")
                        .accessibilityHint("Tap to edit your profile information")
                        
                        Button(action: {
                            // TODO: Implement change password
                        }) {
                            HStack {
                                Image(systemName: "key")
                                    .foregroundColor(.blue)
                                Text("Change Password")
                            }
                        }
                        .accessibilityLabel("Change Password")
                        .accessibilityHint("Tap to change your account password")
                    }
                }
            }
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Dismiss account settings")
                }
            }
        }
    }
}

#Preview {
    AccountSettingsView()
}

