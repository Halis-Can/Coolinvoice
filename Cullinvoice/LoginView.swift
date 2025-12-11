//
//  LoginView.swift
//  Cullinvoice
//
//  Created for Firebase integration
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showingError = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo/Header
            VStack(spacing: 16) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Cullinvoice")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(isSignUp ? "Create your account" : "Sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
            
            // Form
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(isSignUp ? .newPassword : .password)
                
                if authManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Button {
                        Task {
                            await handleAuth()
                        }
                    } label: {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                }
            }
            .padding(.horizontal, 32)
            
            // Toggle Sign Up/Sign In
            Button {
                withAnimation {
                    isSignUp.toggle()
                }
            } label: {
                HStack {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .foregroundStyle(.secondary)
                    Text(isSignUp ? "Sign In" : "Sign Up")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "An error occurred")
        }
        .onChange(of: authManager.errorMessage) { _, newValue in
            if newValue != nil {
                showingError = true
            }
        }
    }
    
    private func handleAuth() async {
        do {
            if isSignUp {
                try await authManager.signUp(email: email, password: password)
            } else {
                try await authManager.signIn(email: email, password: password)
            }
        } catch {
            // Error is handled by authManager.errorMessage
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(FirebaseAuthManager.shared)
}

