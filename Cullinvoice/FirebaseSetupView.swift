//
//  FirebaseSetupView.swift
//  Cullinvoice
//
//  Created for Firebase setup guidance
//

import SwiftUI

struct FirebaseSetupView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("Firebase Setup Required")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("To use cloud sync, you need to set up Firebase:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("1.")
                            .fontWeight(.bold)
                        Text("Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("2.")
                            .fontWeight(.bold)
                        Text("Add an iOS app to your Firebase project")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("3.")
                            .fontWeight(.bold)
                        Text("Download GoogleService-Info.plist from Firebase Console")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("4.")
                            .fontWeight(.bold)
                        Text("Drag GoogleService-Info.plist into your Xcode project (Cullinvoice folder)")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("5.")
                            .fontWeight(.bold)
                        Text("Make sure 'Copy items if needed' is checked")
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Text("6.")
                            .fontWeight(.bold)
                        Text("Restart the app")
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Link(destination: URL(string: "https://console.firebase.google.com/")!) {
                HStack {
                    Image(systemName: "arrow.up.right.square")
                    Text("Open Firebase Console")
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Text("For detailed instructions, see FIREBASE_SETUP.md")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    FirebaseSetupView()
}

