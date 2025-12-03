//
//  MoreView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct MoreView: View {
    @StateObject private var businessManager = BusinessManager.shared
    @State private var showingLogoutSheet = false
    
    var body: some View {
        List {
            Section {
                NavigationLink {
                    BusinessProfileView()
                } label: {
                    HStack {
                        Label("Profile", systemImage: "person.circle.fill")
                        Spacer()
                        if !businessManager.business.name.isEmpty {
                            Text(businessManager.business.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("Business Profile")
            } footer: {
                Text("Set up your business information and logo that will appear on invoices.")
            }
            
            Section("Templates") {
                NavigationLink {
                    Text("Invoice Templates")
                } label: {
                    Label("Invoice Templates", systemImage: "doc.text.fill")
                }
                
                NavigationLink {
                    Text("Estimate Templates")
                } label: {
                    Label("Estimate Templates", systemImage: "doc.fill")
                }
            }
            
            Section("Settings") {
                NavigationLink {
                    Text("Notifications")
                } label: {
                    Label("Notifications", systemImage: "bell.fill")
                }
                
                NavigationLink {
                    Text("Tax Settings")
                } label: {
                    Label("Tax Settings", systemImage: "percent")
                }
                
                NavigationLink {
                    Text("Payment Methods")
                } label: {
                    Label("Payment Methods", systemImage: "creditcard.fill")
                }
            }
            
            Section("Support") {
                Link(destination: URL(string: "https://help.coolinvoice.com")!) {
                    Label("Help & Support", systemImage: "questionmark.circle.fill")
                }
                
                NavigationLink {
                    Text("About")
                } label: {
                    Label("About", systemImage: "info.circle.fill")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingLogoutSheet = true
                } label: {
                    Label("Sign Out", systemImage: "arrow.right.square.fill")
                }
            }
        }
        .navigationTitle("More")
        .sheet(isPresented: $showingLogoutSheet) {
            NavigationStack {
                LogoutView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}

