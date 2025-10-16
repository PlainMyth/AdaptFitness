//
//  LoginView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/16/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var isLoading = false
    @State private var showingSignUp = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo and Welcome
            VStack(spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("AdaptFitness")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track your fitness journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Login Form
            VStack(spacing: 16) {
                // Email field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                // Password field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
                
                // Remember me toggle
                Toggle("Remember Me", isOn: $rememberMe)
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Login button
                Button(action: {
                    Task {
                        await performLogin()
                    }
                }) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Logging in...")
                        }
                    } else {
                        Text("Login")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                // Sign up link
                Button("Don't have an account? Sign up") {
                    showingSignUp = true
                }
                .padding(.top, 10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
                .environmentObject(authManager)
        }
    }
    
    private func performLogin() async {
        isLoading = true
        errorMessage = nil
        
        await authManager.login(email: email, password: password)
        
        if !authManager.isAuthenticated {
            errorMessage = "Invalid email or password"
        }
        
        isLoading = false
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDevice("iPhone 17") // Optional: choose simulator device
            .preferredColorScheme(.light)   // Optional: light/dark mode preview
    }
}
