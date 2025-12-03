//
//  ClientsView.swift
//  Coolinvoice
//
//  Created by Ozde Can on 12/2/25.
//

import SwiftUI

struct ClientsView: View {
    @State private var clients: [Client] = Client.sampleClients
    @State private var searchText = ""
    @State private var showingNewClient = false
    
    var filteredClients: [Client] {
        if searchText.isEmpty {
            return clients
        } else {
            return clients.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText) ||
                client.company.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            if filteredClients.isEmpty {
                ContentUnavailableView(
                    "No Clients",
                    systemImage: "person.2.magnifyingglass",
                    description: Text("No clients match your search")
                )
            } else {
                ForEach(filteredClients) { client in
                    NavigationLink {
                        ClientDetailView(client: client)
                    } label: {
                        ClientRow(client: client)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
        }
        .navigationTitle("Clients")
        .searchable(text: $searchText, prompt: "Search clients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewClient = true
                } label: {
                    Label("New Client", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewClient) {
            Text("New Client")
        }
    }
}

struct ClientRow: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(client.initials)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if !client.company.isEmpty {
                    Text(client.company)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if !client.email.isEmpty {
                    Text(client.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ClientDetailView: View {
    let client: Client
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Text(client.initials)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                    
                    Text(client.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !client.company.isEmpty {
                        Text(client.company)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Contact Information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contact Information")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if !client.email.isEmpty {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                Text(client.email)
                                    .font(.subheadline)
                            }
                        }
                        
                        if !client.phone.isEmpty {
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                Text(client.phone)
                                    .font(.subheadline)
                            }
                        }
                        
                        if !client.address.isEmpty {
                            HStack(alignment: .top) {
                                Image(systemName: "mappin")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                Text(client.address)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Client Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ClientsView()
    }
}

