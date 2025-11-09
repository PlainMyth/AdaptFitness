//
//  SignUpView.swift
//  AdaptFitness
//
//  Created by AI Assistant
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var height = ""
    @State private var weight = ""
    @State private var gender: String = ""
    @State private var activityLevel: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let genders = ["male", "female", "other"]
    let activityLevels = ["sedentary", "lightly_active", "moderately_active", "very_active", "extremely_active"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Join AdaptFitness and start your fitness journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 16) {
                        // Basic Information
                        VStack(spacing: 12) {
                            Text("Basic Information")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.givenName)
                            
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.familyName)
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.newPassword)
                        }
                        
                        // Physical Information
                        VStack(spacing: 12) {
                            Text("Physical Information")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                            
                            HStack {
                                TextField("Height (cm)", text: $height)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                
                                TextField("Weight (kg)", text: $weight)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            Picker("Gender", selection: $gender) {
                                Text("Select Gender").tag("")
                                ForEach(genders, id: \.self) { gender in
                                    Text(gender.capitalized).tag(gender)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Picker("Activity Level", selection: $activityLevel) {
                                Text("Select Activity Level").tag("")
                                ForEach(activityLevels, id: \.self) { level in
                                    Text(level.replacingOccurrences(of: "_", with: " ").capitalized).tag(level)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        // Error message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Sign up button
                        Button(action: {
                            Task {
                                await performSignUp()
                            }
                        }) {
                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Creating account...")
                                }
                            } else {
                                Text("Create Account")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(!isFormValid || isLoading)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        return !email.isEmpty &&
               !password.isEmpty &&
               password == confirmPassword &&
               !firstName.isEmpty &&
               !lastName.isEmpty &&
               password.count >= 6
    }
    
    private func performSignUp() async {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let formatter = ISO8601DateFormatter()
        
        let registerRequest = RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: formatter.string(from: dateOfBirth),
            height: height.isEmpty ? nil : Double(height),
            weight: weight.isEmpty ? nil : Double(weight),
            gender: gender.isEmpty ? nil : gender,
            activityLevel: activityLevel.isEmpty ? nil : activityLevel
        )
        
        await authManager.register(user: registerRequest)
        
        if authManager.isAuthenticated {
            dismiss()
        } else {
            errorMessage = "Failed to create account. Please try again."
        }
        
        isLoading = false
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthManager())
}
