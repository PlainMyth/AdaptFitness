//
//  RegisterView.swift
//  AdaptFitness
//
//  User registration screen
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var localError: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(.top, 20)
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Join AdaptFitness and start your fitness journey")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Form Fields
                    VStack(spacing: 15) {
                        // First Name
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .padding(.horizontal)
                        
                        // Last Name
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .padding(.horizontal)
                        
                        // Email
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(.horizontal)
                        
                        // Password with toggle visibility
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        
                        // Confirm Password
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm Password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                            }
                            
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        
                        // Password Requirements
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Password must contain:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            PasswordRequirement(text: "At least 8 characters", met: password.count >= 8)
                            PasswordRequirement(text: "One uppercase letter", met: password.range(of: "[A-Z]", options: .regularExpression) != nil)
                            PasswordRequirement(text: "One lowercase letter", met: password.range(of: "[a-z]", options: .regularExpression) != nil)
                            PasswordRequirement(text: "One number", met: password.range(of: "[0-9]", options: .regularExpression) != nil)
                            PasswordRequirement(text: "One special character", met: password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]", options: .regularExpression) != nil)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                    
                    // Error Message
                    if let error = localError ?? authManager.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Register Button
                    Button(action: handleRegister) {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(!isFormValid || authManager.isLoading)
                    
                    // Back to Login
                    Button("Already have an account? Log in") {
                        dismiss()
                    }
                    .font(.footnote)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return !email.isEmpty &&
               !password.isEmpty &&
               !firstName.isEmpty &&
               !lastName.isEmpty &&
               password == confirmPassword &&
               isPasswordValid
    }
    
    private var isPasswordValid: Bool {
        let hasMinLength = password.count >= 8
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]", options: .regularExpression) != nil
        
        return hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecial
    }
    
    // MARK: - Actions
    
    private func handleRegister() {
        localError = nil
        
        // Validate passwords match
        guard password == confirmPassword else {
            localError = "Passwords do not match"
            return
        }
        
        // Validate password strength
        guard isPasswordValid else {
            localError = "Password does not meet requirements"
            return
        }
        
        // Call register
        Task {
            do {
                let registerRequest = RegisterRequest(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    dateOfBirth: nil,
                    height: nil,
                    weight: nil,
                    gender: nil,
                    activityLevel: nil
                )
                
                try await authManager.register(user: registerRequest)
                
                // Success - dismiss to go back to app
                dismiss()
                
            } catch {
                // Error is already set in authManager.errorMessage
                print("Registration failed: \(error)")
            }
        }
    }
}

// MARK: - Password Requirement View

struct PasswordRequirement: View {
    let text: String
    let met: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundColor(met ? .green : .gray)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(met ? .green : .gray)
        }
    }
}

// MARK: - Preview

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

