//
//  LoginView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/16/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var showRegisterView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Email field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                    .disabled(authManager.isLoading)
                
                // Password field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .disabled(authManager.isLoading)
                
                // Remember me toggle
                Toggle("Remember Me", isOn: $rememberMe)
                    .padding(.horizontal)
                    .disabled(authManager.isLoading)
                
                // Error message
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                // Login button
                Button(action: handleLogin) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
                .disabled(!isFormValid || authManager.isLoading)
                
                // Sign up link
                Button("Don't have an account? Sign up") {
                    showRegisterView = true
                }
                .font(.footnote)
                .padding(.top, 10)
            }
            .padding()
            .sheet(isPresented: $showRegisterView) {
                RegisterView()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    // MARK: - Actions
    
    private func handleLogin() {
        Task {
            do {
                try await authManager.login(email: email, password: password)
                // isLoggedIn will be set by onChange observer
            } catch {
                // Error is already set in authManager.errorMessage
                print("Login failed: \(error)")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDevice("iPhone 17") // Optional: choose simulator device
            .preferredColorScheme(.light)   // Optional: light/dark mode preview
    }
}
