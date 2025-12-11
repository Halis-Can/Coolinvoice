//
//  CullinvoiceApp.swift
//  Cullinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI
import FirebaseCore

@main
struct CullinvoiceApp: App {
    @StateObject private var authManager = FirebaseAuthManager.shared
    @StateObject private var dataManager = FirebaseDataManager.shared
    @State private var isFirebaseConfigured = false
    
    init() {
        // Initialize Firebase only if GoogleService-Info.plist exists
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           FileManager.default.fileExists(atPath: path) {
            FirebaseApp.configure()
            isFirebaseConfigured = true
        } else {
            print("⚠️ Firebase not configured: GoogleService-Info.plist not found")
            print("📝 Please download GoogleService-Info.plist from Firebase Console and add it to your project")
            isFirebaseConfigured = false
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isFirebaseConfigured {
                if authManager.isAuthenticated {
                    ContentView()
                        .environmentObject(authManager)
                        .environmentObject(dataManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            } else {
                // Show setup screen if Firebase is not configured
                FirebaseSetupView()
            }
        }
    }
}
