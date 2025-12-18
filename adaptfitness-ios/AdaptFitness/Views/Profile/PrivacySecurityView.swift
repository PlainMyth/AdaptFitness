//
//  PrivacySecurityView.swift
//  AdaptFitness
//
//  Privacy & Security Settings View
//

import SwiftUI

struct PrivacySecurityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Data & Privacy")) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Data Encryption")
                        Spacer()
                        Text("Enabled")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Data Encryption: Enabled")
                    
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundColor(.blue)
                        Text("Data Storage")
                        Spacer()
                        Text("Cloud Sync")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Data Storage: Cloud Sync")
                }
                
                Section(header: Text("Account Security")) {
                    Button(action: {
                        // TODO: Implement change password
                    }) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                            Text("Change Password")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityLabel("Change Password")
                    .accessibilityHint("Tap to change your account password")
                    
                    Button(action: {
                        // TODO: Implement two-factor authentication
                    }) {
                        HStack {
                            Image(systemName: "lock.rotation")
                                .foregroundColor(.blue)
                            Text("Two-Factor Authentication")
                            Spacer()
                            Text("Not Available")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Two-Factor Authentication: Not Available")
                    .accessibilityHint("Two-factor authentication is not currently available")
                }
                
                Section(header: Text("Data Management")) {
                    Button(action: {
                        // TODO: Implement export data
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export My Data")
                        }
                    }
                    .accessibilityLabel("Export My Data")
                    .accessibilityHint("Tap to export your account data")
                    
                    Button(role: .destructive, action: {
                        // TODO: Implement delete account
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete Account")
                        }
                    }
                    .accessibilityLabel("Delete Account")
                    .accessibilityHint("Tap to permanently delete your account")
                }
                
                Section(header: Text("About")) {
                    Text("Your data is securely stored and encrypted. We use industry-standard security practices to protect your information.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Privacy & Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Dismiss privacy and security settings")
                }
            }
        }
    }
}

#Preview {
    PrivacySecurityView()
}

