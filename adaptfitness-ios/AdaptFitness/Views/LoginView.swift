//
//  LoginView.swift
//  AdaptFitness
//
//  Created by csuftitan on 9/16/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Logo") // name of your image set
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
                .padding(.horizontal)
            
            // Password field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Remember me toggle
            Toggle("Remember Me", isOn: $rememberMe)
                .padding(.horizontal)
            
            // Login button
            Button(action: {
                print("Logging in with \(email), password: \(password)")
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            // Sign up link
            Button("Don’t have an account? Sign up") {
                print("Go to signup screen")
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDevice("iPhone 17") // Optional: choose simulator device
            .preferredColorScheme(.light)   // Optional: light/dark mode preview
    }
}
